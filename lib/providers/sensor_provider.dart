import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database_providers.dart';
import 'session_provider.dart';

// ── Face-Down Sensor Service ──────────────────────────────────────────────────

/// Watches the accelerometer. Emits `true` when the device is face-down
/// (Z-axis ≤ threshold) for at least [holdDuration].
///
/// ### US 7.3 — Adaptive Sensor Polling
/// The sampling rate is throttled based on session phase to save battery:
///
/// | Phase | SamplingPeriod | approx. rate |
/// |---|---|---|
/// | Active session (running) | 200 ms (fastest) | ~5 Hz |
/// | Idle / any other phase | 2 000 ms (slow) | 0.5 Hz |
///
/// On startup, reads `sensor_z_baseline` from SharedPreferences (written by
/// the onboarding calibration page). Falls back to [_defaultZThreshold] if
/// the key is absent (emulator / calibration skipped).

const double _defaultZThreshold = -8.0; // m/s² — fallback sentinel
const _holdDuration = Duration(milliseconds: 1500);

/// Fast poll period used when a session is actively running.
const _activePeriod = Duration(milliseconds: 200);

/// Slow poll period used when the app is idle (saves significant battery).
const _idlePeriod = Duration(milliseconds: 2000);

class FaceDownNotifier extends StateNotifier<bool> {
  FaceDownNotifier(this._ref) : super(false) {
    _loadThresholdThenSubscribe();
    // React to session phase changes — the ref is available because
    // this notifier is constructed via a Ref-accepting factory (see bottom).
    _ref.listen<SessionPhase>(
      sessionProvider.select((s) => s.phase),
      (prev, next) => _adaptPeriod(next),
      fireImmediately: false,
    );
  }

  final Ref _ref;

  StreamSubscription<AccelerometerEvent>? _sub;
  Timer? _holdTimer;
  Timer? _faceUpHoldTimer;          // Bug 14: hold timer for face-up transition
  bool _isDown = false;
  double _zThreshold = _defaultZThreshold;

  // Bug 14: hysteresis — face-up is only confirmed when Z rises above this
  // (a few units above the face-down threshold to prevent oscillation)
  static const double _faceUpHysteresisOffset = 5.0;
  double get _faceUpThreshold => _zThreshold + _faceUpHysteresisOffset;

  // Bug 14: per-distraction cooldown — prevents multiple logs from one flip
  DateTime? _lastPhoneDistractionAt;
  static const _distractionCooldown = Duration(seconds: 6);
  static const _faceUpHoldDuration = Duration(milliseconds: 800);

  Duration _currentPeriod = _idlePeriod;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> _loadThresholdThenSubscribe() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble('sensor_z_baseline');
    if (saved != null) _zThreshold = saved;
    _subscribe(_currentPeriod);
  }

  // ── Stream management ─────────────────────────────────────────────────────

  /// Subscribe (or re-subscribe) with the given [period].
  void _subscribe(Duration period) {
    _sub?.cancel();
    _currentPeriod = period;
    _sub = accelerometerEventStream(
      samplingPeriod: period,
    ).listen(_onEvent, onError: (_) {});
  }

  /// Called whenever the session phase changes. Switches between fast
  /// (active) and slow (idle) sampling without losing the z-threshold or
  /// hold-timer state.
  void _adaptPeriod(SessionPhase phase) {
    final target = phase == SessionPhase.active ? _activePeriod : _idlePeriod;
    if (target == _currentPeriod) return; // no change
    _subscribe(target);
  }

  // ── Event handler ─────────────────────────────────────────────────────────

  void _onEvent(AccelerometerEvent e) {
    final nowDown = e.z <= _zThreshold;
    // Bug 14: use hysteresis gap — face-up only triggers when Z rises well
    // above the face-down threshold, preventing oscillation logs.
    final nowUp = e.z >= _faceUpThreshold;

    if (nowDown && !_isDown) {
      // Start hold timer for face-down detection (session start trigger)
      _faceUpHoldTimer?.cancel(); // cancel any pending face-up detection
      _isDown = true;
      _holdTimer = Timer(_holdDuration, () {
        if (_isDown) state = true;
      });
    } else if (nowUp && _isDown) {
      // Bug 10 fix + Bug 14 fix: phone clearly face-up during active session.
      // Use a hold timer so brief oscillations don't count.
      _isDown = false;
      _holdTimer?.cancel();

      _faceUpHoldTimer?.cancel();
      _faceUpHoldTimer = Timer(_faceUpHoldDuration, () {
        _logPhoneDistraction();
      });
    } else if (!nowUp && !nowDown && _isDown) {
      // Phone is mid-transition — cancel any pending face-up log.
      _faceUpHoldTimer?.cancel();
    }
  }

  /// Log a phone-flip distraction, subject to cooldown check.
  void _logPhoneDistraction() {
    // Bug 14: cooldown prevents multiple logs within 6 seconds
    final now = DateTime.now();
    if (_lastPhoneDistractionAt != null &&
        now.difference(_lastPhoneDistractionAt!) < _distractionCooldown) {
      return;
    }

    final phase = _ref.read(sessionProvider).phase;
    if (phase != SessionPhase.active) return;

    // Bug 15: respect the flip-to-start toggle — if disabled, no auto-distraction
    final flipEnabled =
        _ref.read(sessionProvider.notifier).isFlipToStartEnabled;
    if (!flipEnabled) return;

    _lastPhoneDistractionAt = now;
    _ref.read(sessionProvider.notifier).addLap(
      trigger: DistractionTrigger.phone,
      note: 'auto: phone flipped up',
    );
  }

  /// Reset after the start has been consumed
  void consume() => state = false;

  @override
  void dispose() {
    _sub?.cancel();
    _holdTimer?.cancel();
    _faceUpHoldTimer?.cancel(); // Bug 14: cancel face-up timer on dispose
    super.dispose();
  }
}

final faceDownStartProvider = StateNotifierProvider<FaceDownNotifier, bool>(
  (ref) => FaceDownNotifier(ref),
);

// ── Zombie Session Detection ──────────────────────────────────────────────────

/// Represents a session that started but was never cleanly finished
/// (app was force-quit or crashed during an active session).
class ZombieSession {
  final int dbSessionId;
  final DateTime startedAt;
  final String category;

  const ZombieSession({
    required this.dbSessionId,
    required this.startedAt,
    required this.category,
  });

  Duration get duration => DateTime.now().difference(startedAt);
}

/// Provides a [ZombieSession] if there's an orphaned incomplete session
/// from a previous launch (app was force-quit or crashed mid-session).
/// Returns null if everything was cleanly finished.
final zombieSessionProvider = FutureProvider<ZombieSession?>((ref) async {
  final dao = ref.read(sessionDaoProvider);
  final incomplete = await dao.findIncomplete();
  if (incomplete == null) return null;
  return ZombieSession(
    dbSessionId: incomplete.id,
    startedAt: DateTime.fromMillisecondsSinceEpoch(incomplete.startedAt),
    category: incomplete.category,
  );
});

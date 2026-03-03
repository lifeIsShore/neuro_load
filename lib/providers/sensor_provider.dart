import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database_providers.dart';

// ── Face-Down Sensor Service ─────────────────────────────────────────────────

/// Watches the accelerometer. Emits `true` when the device is face-down
/// (Z-axis ≤ threshold) for at least [holdDuration].
///
/// On startup, reads `sensor_z_baseline` from SharedPreferences (written by
/// the onboarding calibration page). Falls back to [_defaultZThreshold] if
/// the key is absent (emulator / calibration skipped).

const double _defaultZThreshold = -8.0; // m/s² — fallback sentinel
const _holdDuration = Duration(milliseconds: 1500);

class FaceDownNotifier extends StateNotifier<bool> {
  FaceDownNotifier() : super(false) {
    _loadThresholdThenSubscribe();
  }

  StreamSubscription<AccelerometerEvent>? _sub;
  Timer? _holdTimer;
  bool _isDown = false;
  double _zThreshold = _defaultZThreshold;

  Future<void> _loadThresholdThenSubscribe() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble('sensor_z_baseline');
    if (saved != null) _zThreshold = saved;
    _subscribe();
  }

  void _subscribe() {
    _sub = accelerometerEventStream(
      samplingPeriod: SensorInterval.normalInterval,
    ).listen(_onEvent, onError: (_) {});
  }

  void _onEvent(AccelerometerEvent e) {
    final nowDown = e.z <= _zThreshold;

    if (nowDown && !_isDown) {
      // Start hold timer
      _isDown = true;
      _holdTimer = Timer(_holdDuration, () {
        if (_isDown) state = true;
      });
    } else if (!nowDown && _isDown) {
      _isDown = false;
      _holdTimer?.cancel();
    }
  }

  /// Reset after the start has been consumed
  void consume() => state = false;

  @override
  void dispose() {
    _sub?.cancel();
    _holdTimer?.cancel();
    super.dispose();
  }
}

final faceDownStartProvider = StateNotifierProvider<FaceDownNotifier, bool>(
  (ref) => FaceDownNotifier(),
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

// ── Face-Down Sensor Service ─────────────────────────────────────────────────

/// Watches the accelerometer. Emits `true` when the device is face-down
/// (Z-axis ≤ threshold) for at least [holdDuration].
///
/// Usage:
///   ref.listen(faceDownStartProvider, (_, event) {
///     if (event.valueOrNull == true) ref.read(sessionProvider.notifier).startSession();
///   });

const _zThreshold = -8.0; // m/s² — negative Z means face-down
const _holdDuration = Duration(milliseconds: 1500);

class FaceDownNotifier extends StateNotifier<bool> {
  FaceDownNotifier() : super(false) {
    _subscribe();
  }

  StreamSubscription<AccelerometerEvent>? _sub;
  Timer? _holdTimer;
  bool _isDown = false;

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

/// Provides a ZombieSession if there's an orphaned incomplete session
/// from a previous launch.
final zombieSessionProvider = FutureProvider<ZombieSession?>((ref) async {
  // Import lazily to avoid circular dependency
  return null; // Populated after DB wiring in app_database extension
});

// ── Zombie Recovery Widget ────────────────────────────────────────────────────

class ZombieRecoveryModal extends StatelessWidget {
  final ZombieSession zombie;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  const ZombieRecoveryModal({
    super.key,
    required this.zombie,
    required this.onResume,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final mins = zombie.duration.inMinutes;
    return AlertDialog(
      title: const Text('Session Still Running?'),
      content: Text(
        'We found an unfinished ${zombie.category} session (~$mins min). '
        'What would you like to do?',
      ),
      actions: [
        TextButton(
          onPressed: onDiscard,
          child: const Text('Discard'),
        ),
        ElevatedButton(
          onPressed: onResume,
          child: const Text('Continue Session'),
        ),
      ],
    );
  }
}

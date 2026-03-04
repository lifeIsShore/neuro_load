import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Runs in the foreground-task isolate.
///
/// Emits a `'tick'` string to the main isolate every second so that
/// [SessionNotifier.tick()] continues regardless of whether the Flutter
/// widget tree is backgrounded by Android.
class ForegroundTaskHandler extends TaskHandler {
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      FlutterForegroundTask.sendDataToMain('tick');
    });
  }

  // We drive ticks via our own timer above, so onRepeatEvent is a no-op.
  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _timer?.cancel();
    _timer = null;
  }

  // Tapping the foreground notification brings the user back to the timer.
  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/timer');
  }
}

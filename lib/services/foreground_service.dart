import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'foreground_task_handler.dart';

/// Thin wrapper around [FlutterForegroundTask] that manages the session
/// foreground service lifecycle.
///
/// Call [start] when a session begins and [stop] when it ends or is reset.
abstract class ForegroundService {
  // ── Configuration ────────────────────────────────────────────────────────

  static void _configure() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'neuroload_session',
        channelName: 'Active Session',
        channelDescription: 'Shows while a NeuroLoad focus session is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        playSound: false,
      ),
      // iOS: no background service but we still init to avoid throws.
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        // Our TaskHandler drives its own 1-second timer, so we set the repeat
        // interval to a long value to avoid redundant onRepeatEvent callbacks.
        eventAction: ForegroundTaskEventAction.repeat(60000),
        autoRunOnBoot: false,
        allowWakeLock: true,
      ),
    );
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// Starts the foreground service. Safe to call multiple times — if the
  /// service is already running this updates the notification text.
  static Future<void> start({required String category}) async {
    _configure();

    final title = '$category Session';
    const body = 'Focus session in progress…';

    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) {
      await FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: body,
      );
    } else {
      await FlutterForegroundTask.startService(
        notificationTitle: title,
        notificationText: body,
        callback: startCallback,
      );
    }
  }

  /// Updates the notification body without restarting the service.
  static Future<void> updateNotification({
    required String category,
    required String elapsed,
  }) async {
    if (!await FlutterForegroundTask.isRunningService) return;
    await FlutterForegroundTask.updateService(
      notificationTitle: '$category Session',
      notificationText: elapsed,
    );
  }

  /// Stops the foreground service and dismisses its notification.
  static Future<void> stop() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}

// ── Top-level entry point for the foreground-task isolate ────────────────────
// Must be a top-level function — called by flutter_foreground_task on Android.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

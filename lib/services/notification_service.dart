import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

// ── Notification Service ─────────────────────────────────────────────────────

/// Bug 09 (Android) — action button callback.
/// [SessionNotifier] registers itself here when active so the notification
/// action can call addLap() without needing a BuildContext or Riverpod ref
/// from the notification layer.
typedef DistractionCallback = void Function();

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Registered by [SessionNotifier] when a session is active.
  /// Cleared to null when the session ends.
  static DistractionCallback? onNotificationDistraction;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database + local zone
    tz.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channels
    if (Platform.isAndroid) {
      await _createChannels();
    }

    _initialized = true;
  }

  static Future<void> _createChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'focus_session',
        'Focus Session',
        description: 'Ongoing focus session status notification',
        importance: Importance.low,
        enableVibration: false,
        playSound: false,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'reminders',
        'Training Reminders',
        description: 'Daily focus training reminders',
        importance: Importance.defaultImportance,
      ),
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: id=${response.id} action=${response.actionId} payload=${response.payload}');
    // Bug 09 (Android): fire the distraction callback when the user taps
    // the "I Got Distracted" action button on the session notification.
    if (response.actionId == 'distracted') {
      onNotificationDistraction?.call();
    }
  }

  // ── Foreground Session Notification ─────────────────────────────────────────

  /// Bug 09 (Android) — action button shown in the ongoing session notification.
  static const _distractedAction = AndroidNotificationAction(
    'distracted',
    'I Got Distracted',
    showsUserInterface: false, // handles silently; no app re-open needed
    cancelNotification: false,
  );

  /// Shows a persistent "session in progress" notification on Android,
  /// with an "I Got Distracted" action button (Bug 09).
  static Future<void> showSessionActive({
    required String category,
    required Duration elapsed,
  }) async {
    final mins = elapsed.inMinutes;
    final secs = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

    await _plugin.show(
      1,
      'NeuroLoad — In Flow',
      '$category · $mins:$secs',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'focus_session',
          'Focus Session',
          channelDescription: 'Active focus session',
          ongoing: true,
          autoCancel: false,
          importance: Importance.low,
          priority: Priority.low,
          showWhen: false,
          icon: '@mipmap/ic_launcher',
          // Bug 09: action button lets users log a distraction from the
          // lock screen / notification shade without opening the app.
          actions: [_distractedAction],
        ),
      ),
      payload: 'session_active',
    );
  }

  /// Dismisses the session-active notification.
  static Future<void> dismissSessionNotification() => _plugin.cancel(1);

  // ── Daily Reminder ───────────────────────────────────────────────────────────

  /// Schedules a daily notification at the exact [time] chosen by the user.
  /// Uses [tz.TZDateTime] + [DateTimeComponents.time] for timezone-correct
  /// daily recurrence (unlike periodicallyShow which ignores the time param).
  static Future<void> scheduleDailyReminder({
    required TimeOfDay time,
  }) async {
    // Cancel any previous reminder before scheduling a new one.
    await cancelDailyReminder();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the chosen time has already passed today, start from tomorrow.
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      2,
      'Time to Train 🧠',
      'Your focus gym is waiting.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Training Reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
      payload: 'daily_reminder',
    );
  }

  static Future<void> cancelDailyReminder() => _plugin.cancel(2);

  // ── Rest Reminder ────────────────────────────────────────────────────────────

  static Future<void> showRestComplete() async {
    await _plugin.show(
      3,
      'Rest Complete',
      'Ready for one more rep? 💪',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Training Reminders',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}

// ── Riverpod Provider ─────────────────────────────────────────────────────────

/// Call initialize() in main() before runApp.
final notificationServiceProvider = Provider<NotificationService>(
  (_) => NotificationService(),
);

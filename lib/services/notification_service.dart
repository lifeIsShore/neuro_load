import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

// ── Notification Service ─────────────────────────────────────────────────────

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

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
    // Deep-link handling — can be extended
    debugPrint('Notification tapped: ${response.payload}');
  }

  // ── Foreground Session Notification ─────────────────────────────────────────

  /// Shows a persistent "session in progress" notification on Android.
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

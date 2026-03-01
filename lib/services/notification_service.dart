import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Notification Service ─────────────────────────────────────────────────────

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

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
      NotificationDetails(
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

  static Future<void> scheduleDailyReminder({
    required TimeOfDay time,
  }) async {
    await _plugin.periodicallyShow(
      2,
      'Time to Train 🧠',
      'Your focus gym is waiting.',
      RepeatInterval.daily,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Training Reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
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

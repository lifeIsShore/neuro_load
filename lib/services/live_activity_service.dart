import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// ── Feature 01: iOS Live Activity Service ────────────────────────────────────
//
// ⚠️  TODO — iOS IMPLEMENTATION NOT YET DONE ⚠️
// ================================================================
// Feature 01 is ANDROID ONLY for now. The iOS Live Activity side
// is stubbed and requires native Xcode work before it will function.
//
// What still needs to be built in Xcode:
//   1. New Widget Extension target: "NeuroLoadLiveActivity"
//   2. NeuroLoadAttributes.swift (ActivityAttributes + ContentState)
//   3. SwiftUI lock-screen + Dynamic Island view
//   4. MethodChannel handler in AppDelegate.swift responding to:
//        startActivity / updateActivity / endActivity / areActivitiesEnabled
//   5. "Distracted" button tap → open neuroload://distracted deeplink
//      (already handled in router.dart on the Flutter side)
//   6. ios/Runner/Info.plist entries:
//        <key>NSSupportsLiveActivities</key><true/>
//        <key>NSSupportsLiveActivitiesFrequentUpdates</key><true/>
//
// The Flutter call sites in session_provider.dart are already wired —
// they activate automatically once the native side exists.
// ================================================================
//
// All methods in this class are no-ops on Android (Platform.isIOS guard).

class LiveActivityService {
  static const _channel = MethodChannel('neuroload/live_activity');

  static bool _isRunning = false;

  /// Start a Live Activity when a session begins.
  ///
  /// On iOS 16.2+, this creates an ActivityKit activity that appears on
  /// the Dynamic Island (iPhone 14 Pro+) and as a lock-screen banner.
  /// Silently no-ops on Android and older iOS.
  static Future<void> start({
    required String sessionId,
    required String category,
    String subCategory = '',
  }) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod<void>('startActivity', {
        'sessionId': sessionId,
        'category': category,
        'subCategory': subCategory,
        'elapsedSeconds': 0,
        'lapCount': 0,
      });
      _isRunning = true;
    } on PlatformException catch (e) {
      // Live Activities may be disabled by the user in Settings → NeuroLoad.
      // Degrade gracefully — the session continues without the Live Activity.
      debugPrint('[LiveActivityService] start failed: ${e.message}');
      _isRunning = false;
    }
  }

  /// Update the Live Activity's content state every 60 seconds (or on any
  /// lap event) to keep the lock-screen timer and lap count current.
  static Future<void> update({
    required int elapsedSeconds,
    required int lapCount,
  }) async {
    if (!Platform.isIOS || !_isRunning) return;
    try {
      await _channel.invokeMethod<void>('updateActivity', {
        'elapsedSeconds': elapsedSeconds,
        'lapCount': lapCount,
      });
    } on PlatformException catch (e) {
      debugPrint('[LiveActivityService] update failed: ${e.message}');
    }
  }

  /// End the Live Activity when the session finishes.
  /// The activity will animate off the Dynamic Island / lock screen.
  static Future<void> end() async {
    if (!Platform.isIOS || !_isRunning) return;
    try {
      await _channel.invokeMethod<void>('endActivity');
      _isRunning = false;
    } on PlatformException catch (e) {
      debugPrint('[LiveActivityService] end failed: ${e.message}');
    }
  }

  /// Returns whether Live Activities are enabled for this app.
  /// Can be used to show the "Enable Live Activities in Settings" prompt.
  static Future<bool> areActivitiesEnabled() async {
    if (!Platform.isIOS) return false;
    try {
      final result =
          await _channel.invokeMethod<bool>('areActivitiesEnabled') ?? false;
      return result;
    } on PlatformException {
      return false;
    }
  }
}

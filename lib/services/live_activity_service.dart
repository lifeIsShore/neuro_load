import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// ── Feature 01: iOS Live Activity Service ────────────────────────────────────
//
// This service is the Flutter-side bridge to the native iOS ActivityKit
// Live Activity extension.
//
// NATIVE SIDE REQUIREMENT (not implemented here — requires Xcode):
//   A Swift Widget Extension target named "NeuroLoadLiveActivity" must be
//   created in the Xcode project.  It defines NeuroLoadAttributes conforming
//   to ActivityAttributes and the SwiftUI lock-screen + Dynamic Island views.
//
//   The extension communicates back to Flutter via the same MethodChannel
//   when the user taps the "Distracted" button on the Live Activity:
//     channel.invokeMethod('onLiveActivityDistraction')
//   which triggers the deeplink neuroload://distracted handled in router.dart.
//
// PLIST REQUIREMENTS (ios/Runner/Info.plist):
//   <key>NSSupportsLiveActivities</key><true/>
//   <key>NSSupportsLiveActivitiesFrequentUpdates</key><true/>
//
// This Dart class is a no-op on Android — all calls short-circuit on
// Platform.isIOS checks.

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

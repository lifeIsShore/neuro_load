import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// ── Feature 03: Home Screen Widget Bridge ────────────────────────────────────
//
// Flutter-side bridge to the native home screen widget on both platforms.
//
// Android: Communicates with NeuroLoadWidget.kt (Jetpack Glance) via
//   MethodChannel. The Kotlin handler updates GlanceState and triggers a
//   widget redraw. Called from SessionNotifier every 60 s and on start/end.
//
// iOS: Uses the `home_widget` App Group approach.
//   Writes shared UserDefaults to the App Group "group.com.neuroload.app"
//   and calls updateWidget() to reload the WidgetKit timeline.
//   The Swift WidgetKit extension reads from the same UserDefaults suite.
//
// Both platforms use the same MethodChannel so the Dart layer is unified.

class WidgetUpdateService {
  static const _channel = MethodChannel('neuroload/widget');

  /// Push new session state to the home screen widget.
  ///
  /// Called from [SessionNotifier]:
  ///   - [startSession()] immediately after session begins
  ///   - [tick()] every 60 seconds while active
  ///   - [addLap()] whenever a distraction is logged (updates lap count)
  static Future<void> update({
    required bool isActive,
    required int elapsedSeconds,
    required String category,
    required String subCategory,
    required int lapCount,
    int? lastSessionMinutes,
    String? lastSessionCategory,
  }) async {
    try {
      await _channel.invokeMethod<void>('updateWidget', {
        'isActive': isActive,
        'elapsedSeconds': elapsedSeconds,
        'category': category,
        'subCategory': subCategory,
        'lapCount': lapCount,
        if (lastSessionMinutes != null) 'lastSessionMinutes': lastSessionMinutes,
        if (lastSessionCategory != null) 'lastSessionCategory': lastSessionCategory,
      });
    } on PlatformException catch (e) {
      debugPrint('[WidgetUpdateService] update failed: ${e.message}');
    }
  }

  /// Clear the widget to idle state when the session ends.
  ///
  /// Optionally pass the just-finished session's duration and category
  /// so the idle widget can show "Last session · X min · Category".
  static Future<void> clear({
    int? lastSessionMinutes,
    String? lastSessionCategory,
  }) async {
    try {
      await _channel.invokeMethod<void>('clearWidget', {
        if (lastSessionMinutes != null) 'lastSessionMinutes': lastSessionMinutes,
        if (lastSessionCategory != null) 'lastSessionCategory': lastSessionCategory,
      });
    } on PlatformException catch (e) {
      debugPrint('[WidgetUpdateService] clear failed: ${e.message}');
    }
  }
}

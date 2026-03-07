# FEATURE-01 — Live Lock Screen: Session Timer + One-Tap Distraction Logging

**Status:** Android implemented — iOS Live Activities pending native Xcode setup  
**Android:** Complete (notification visibility, live timer, lock-screen action button)  
**iOS:** NOT YET IMPLEMENTED — requires native Swift WidgetExtension target in Xcode  
**Priority:** High  
**Reported:** 2026-03-07  
**Type:** New Feature  
**Module:** `notification_service.dart`, `foreground_task_handler.dart`, new `live_activity_service.dart` (iOS)  
**Platforms:** Android + iOS  
**Related:** BUG-09 (Lock Screen Widget — partial implementation exists for Android notification action button), BUG-15 (Flip to Start Toggle)

---

## Why This Feature Exists

NeuroLoad's core purpose is to reduce distraction and keep the user in deep focus. A critical contradiction exists today:

> **If the user gets distracted and wants to log it, they must:**  
> 1. Wake the phone.  
> 2. Unlock it (Face ID / PIN / pattern).  
> 3. Wait for the app to come to foreground.  
> 4. Tap the DISTRACTED button.  
> 5. Select a trigger from the modal.  
>  
> This process itself takes 10–20 seconds and requires full attention — the exact opposite of what NeuroLoad is trying to achieve.

The lock screen must become a **zero-friction interface** where the user can:
- See their session timer at a glance.
- Log a distraction in **one tap**, without unlocking.

This feature closes the gap between intent (tracking distractions accurately) and friction (the unlock ceremony).

---

## Feature Description

When a NeuroLoad session is active and the screen locks (or the user turns the screen off), the device lock screen shows a **persistent NeuroLoad widget** containing:

1. **Live session timer** — elapsed time, updating every minute (or in real time on iOS).
2. **Session context chip** — category label (e.g., "STUDY") and sub-category if set.
3. **"I Got Distracted" action button** — one tap logs a distraction of type `DistractionTrigger.phone` immediately, without opening the app.
4. **(Optional v2)** A distraction trigger quick-select — a second tap (or long press) lets the user choose Phone / Noise / Thought before confirming. For v1, single-tap defaults to Phone trigger with note `"via lock screen"`.

The widget disappears automatically when the session ends.

---

## Platform Implementation

### Android — Foreground Service Notification (Extends Existing BUG-09 Work)

Android's foreground service notification already appears in the notification shade. BUG-09 partially implemented an action button. This feature extends it to also appear prominently on the **lock screen** and updates the notification to show the live timer.

**Required changes:**

#### a) Notification Visibility
Set `visibility: NotificationVisibility.public` on the `AndroidNotificationDetails` so the full notification content (not just the app name) is shown on the lock screen:

```dart
// notification_service.dart → showSessionActive()
const NotificationDetails(
  android: AndroidNotificationDetails(
    'focus_session',
    'Focus Session',
    ...
    visibility: NotificationVisibility.public,  // ADD THIS
    ongoing: true,
    actions: [_distractedAction],
  ),
),
```

#### b) Live Timer in Notification
Update the notification content string every **60 seconds** (already triggered in `SessionNotifier.tick()` every 60 ticks) to show the current elapsed time. This gives a "live" feel within Android's notification constraints.

#### c) Action Button — Lock Screen Behaviour
The existing `_distractedAction` with `showsUserInterface: false` already handles the tap silently. The `onNotificationDistraction` callback in `NotificationService` fires `addLap()` on the active session. This works on the lock screen **without unlocking**, provided `showsUserInterface: false` and the notification channel importance is set correctly.

**Permissions required (Android):**
- `POST_NOTIFICATIONS` (Android 13+) — already needed for foreground service.
- `USE_FULL_SCREEN_INTENT` — needed if a heads-up / full-screen lock screen presence is desired (optional, for more prominent display).
- No additional permissions needed for the action button on lock screen — it works via the existing foreground service.

**Android manifest additions:**
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>  <!-- optional -->
```

---

### iOS — Live Activities (ActivityKit)

iOS requires a completely separate mechanism: **Live Activities** via the `ActivityKit` framework (iOS 16.2+). Live Activities appear on the Dynamic Island (iPhone 14 Pro and newer) and on the Lock Screen as an expanded banner.

**Required additions:**

#### a) Create a NeuroLoad Widget Extension Target
A new Flutter plugin or native Swift target must be created:
- `NeuroLoadLiveActivity.swift` — defines the `ActivityAttributes` and SwiftUI view.
- Communicates with the Flutter layer via `MethodChannel` or the `live_activities` Flutter package.

**Recommended package:** [`live_activities`](https://pub.dev/packages/live_activities) — abstracts ActivityKit for Flutter.

#### b) Define `ActivityAttributes`
```swift
// Swift (WidgetExtension target)
struct NeuroLoadAttributes: ActivityAttributes {
    public typealias NeuroLoadStatus = ContentState

    public struct ContentState: Codable, Hashable {
        var elapsedSeconds: Int
        var category: String
        var subCategory: String
        var lapCount: Int
    }

    var sessionId: String
}
```

#### c) SwiftUI Lock Screen View
The lock screen expanded view shows:
- `NEUROLOAD · [CATEGORY]` header label.
- Large elapsed time display (`MM:SS` or `HH:MM:SS`).
- Sub-category text (if set).
- A tappable **"Distracted"** button with a phone icon — this deeplinks into the app with a specific URL scheme that auto-logs the distraction without showing any modal.

#### d) Flutter → Native Bridge
When `SessionNotifier.startSession()` is called, the Flutter layer sends a `MethodChannel` message to start the Live Activity:
```dart
// live_activity_service.dart (new)
class LiveActivityService {
  static const _channel = MethodChannel('neuroload/live_activity');

  static Future<void> start({
    required String sessionId,
    required String category,
    String subCategory = '',
  }) async {
    await _channel.invokeMethod('startActivity', {
      'sessionId': sessionId,
      'category': category,
      'subCategory': subCategory,
      'elapsedSeconds': 0,
    });
  }

  static Future<void> update({
    required int elapsedSeconds,
    required int lapCount,
  }) async {
    await _channel.invokeMethod('updateActivity', {
      'elapsedSeconds': elapsedSeconds,
      'lapCount': lapCount,
    });
  }

  static Future<void> end() async {
    await _channel.invokeMethod('endActivity');
  }
}
```

#### e) Update Hook in `SessionNotifier`
```dart
// session_provider.dart → tick()
if (_tickCount % 60 == 0) {
  NotificationService.showSessionActive(...);
  LiveActivityService.update(          // ADD
    elapsedSeconds: state.elapsed.inSeconds,
    lapCount: state.laps.length,
  );
}
```

#### f) Distraction Deeplink Handler
When the user taps "Distracted" on the Live Activity, iOS sends a URL like `neuroload://distracted`. The app must handle this in `AppDelegate.swift` or via `go_router`'s deep link support:
```dart
// router.dart — add a route handler
GoRoute(
  path: '/distracted',
  redirect: (context, state) {
    // Log distraction silently
    ProviderScope.containerOf(context)
        .read(sessionProvider.notifier)
        .addLap(trigger: DistractionTrigger.phone, note: 'via lock screen');
    return '/timer'; // return to timer, or null to stay on current screen
  },
),
```

**iOS permissions required (Info.plist):**
```xml
<key>NSSupportsLiveActivities</key>
<true/>
<key>NSSupportsLiveActivitiesFrequentUpdates</key>
<true/>
```

---

## Distraction Logging Flow (Both Platforms)

```
User taps "Distracted" on lock screen
  ├─ Android: NotificationService.onNotificationDistraction() callback fires
  │    └─ SessionNotifier.addLap(trigger: phone, note: "via lock screen")
  └─ iOS: App receives deeplink neuroload://distracted
       └─ SessionNotifier.addLap(trigger: phone, note: "via lock screen")

addLap() → Lap inserted into session state
         → DB updated (via finishSession at end, or autoSave for safety)
         → LapFeed on timer screen reflects the new entry when app reopens
```

No unlock required. No modal. No navigation. One tap.

---

## Permission Request Flow

The app must request the necessary permissions gracefully, explaining the user benefit before the system permission dialog appears:

### Android
Show an in-app explanation screen/bottom sheet when the user starts their **first** session:  
*"NeuroLoad can show your focus timer on the lock screen so you can log distractions without unlocking. Allow notifications?"*  
→ Then trigger `POST_NOTIFICATIONS` permission request.

### iOS  
Before starting the first Live Activity, check `ActivityAuthorizationInfo.areActivitiesEnabled`. If `false`, show an explanation:  
*"NeuroLoad can show your session on the Dynamic Island and Lock Screen. Enable Live Activities in Settings → NeuroLoad → Live Activities."*

---

## Acceptance Criteria

### Android
- [ ] The foreground notification is visible on the lock screen without unlocking (not hidden/redacted).
- [ ] The notification shows the current elapsed session time, updated every 60 seconds.
- [ ] The "I Got Distracted" action button is visible and tappable from the lock screen.
- [ ] Tapping it logs a `DistractionTrigger.phone` lap with note `"via lock screen"` **without opening the app**.
- [ ] The notification disappears when the session ends.
- [ ] A permission explanation screen is shown before requesting `POST_NOTIFICATIONS` on first use.

### iOS
- [ ] A Live Activity appears on the lock screen when a session starts.
- [ ] The Live Activity displays elapsed time (updated every 60 seconds or more frequently if `NSSupportsLiveActivitiesFrequentUpdates` is set).
- [ ] The Live Activity shows category and sub-category.
- [ ] A "Distracted" button is present and tappable on the lock screen UI.
- [ ] Tapping it logs a distraction lap without requiring the app to fully foreground.
- [ ] The Live Activity ends when the session ends.
- [ ] An explanation screen is shown if Live Activities are disabled, with a link to Settings.

### Both Platforms
- [ ] Distraction logged via lock screen appears in the lap feed when the user opens the app.
- [ ] The distraction count in the session summary correctly includes lock-screen-logged laps.
- [ ] Quality Score and Focus Density correctly account for lock-screen-logged laps.

---

## Out of Scope for v1

- Showing the earned break time on the lock screen.
- Choosing a trigger type (Phone / Noise / Thought) from the lock screen — all lock screen taps default to `phone` trigger.
- Showing a lap count history or chart on the lock screen.
- Android 12 and below lock screen full-screen intent (covered by `USE_FULL_SCREEN_INTENT` as optional only).

---

## Dependencies

- Flutter package: [`live_activities`](https://pub.dev/packages/live_activities) (or custom native module).
- Existing: `flutter_local_notifications` (Android notification, already present).
- Existing: `flutter_foreground_task` (Android foreground service, already present).
- iOS 16.2+ for Live Activities (graceful degradation on older iOS: falls back to standard notification, same as Android behaviour).

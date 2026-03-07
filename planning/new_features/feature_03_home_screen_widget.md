# FEATURE-03 — Home Screen Widget: FlowState Timer at a Glance

**Status:** Proposed  
**Priority:** High  
**Reported:** 2026-03-07  
**Type:** New Feature  
**Module:** New native widget extension (iOS) + App Widget (Android) + `notification_service.dart`  
**Platforms:** Android + iOS  
**Related:** FEATURE-01 (Lock Screen Timer — shares some infrastructure), BUG-09 (Foreground notification)

---

## Why This Feature Exists

The single biggest friction point between a user and their next focus session is **the number of taps required to start one**.

Currently:
1. Unlock phone
2. Find NeuroLoad on the home screen
3. Open the app
4. Wait for the setup screen to load
5. Select a category
6. Tap START SESSION

That is a 6-step process. For a tool that is supposed to help people focus *more often*, that is too many steps. Each one is a small opportunity to get distracted and not start at all.

A home screen widget reduces this to:
1. Glance at widget (session status visible without unlocking)
2. One tap → straight into the session

This is not a cosmetic feature. It is a **retention and frequency driver**. Users who see the NeuroLoad widget every time they look at their phone are reminded to focus. Users who can start a session in one tap do so more often. High frequency of use is the single most important predictor of long-term retention for a habit-forming productivity app.

The widget also serves as a **passive billboard** — other people see it on the user's home screen and ask what it is.

---

## What the Widget Shows

The widget has two states: **Idle** (no session running) and **Active** (session in progress).

### Idle State
- App name: "NEUROLOAD" in small label text
- A single clear CTA: **"Start Session"** — a rounded button or the entire widget is tappable
- Optional: last session summary in tiny text (e.g., "Yesterday · 47 min · Study") — shown only if data exists
- Optional: a subtle motivational line from the session philosophy (e.g., "Your 1RM is 34 min. Beat it.") — pulled from the last computed 1RM

The idle state widget is the most important one. It appears on the user's home screen every day and acts as a constant low-friction invitation to start.

### Active State
- Live elapsed timer: **34:21** — large, readable, updating every minute
- Category label: e.g., "STUDY" or "WORK"
- Sub-category text (if set): e.g., "Chapter 5 — Econometrics"
- A **"Distracted"** button (small, clearly secondary to the timer)
- The timer digits should feel substantial — this is the focal point

The active state turns the home screen itself into part of the session experience. The user can glance at their phone to check the time without opening it and still feel the session is real and in progress.

---

## Widget Size

One widget size is supported at launch. On Android this is a **4×2 grid cell** (approximately 180×90 dp). On iOS this is the **medium widget** in the standard widget size family (approximately 160×180 dp logical units).

No small or large variants in v1. Small would not have room for both the timer and a distraction button. Large adds unnecessary complexity.

---

## Platform Implementation

### Android — App Widget (Glance API)

Android home screen widgets are implemented using Jetpack's **Glance** library, which is the recommended modern approach and works well with Flutter projects via a native Kotlin module.

**Required additions:**

#### a) New Kotlin Widget Receiver + Provider

A new file `NeuroLoadWidget.kt` in the Android module (`android/app/src/main/kotlin/...`):

```kotlin
@GlanceAppWidget
class NeuroLoadWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = currentState<Preferences>()
        val isActive = prefs[booleanPreferencesKey("session_active")] ?: false
        val elapsed  = prefs[intPreferencesKey("elapsed_seconds")] ?: 0
        val category = prefs[stringPreferencesKey("category")] ?: ""

        provideContent {
            if (isActive) {
                ActiveSessionWidget(elapsed, category)
            } else {
                IdleWidget()
            }
        }
    }
}

@GlanceAppWidgetReceiver
class NeuroLoadWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = NeuroLoadWidget()
}
```

#### b) AndroidManifest.xml

```xml
<receiver android:name=".NeuroLoadWidgetReceiver" android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE"/>
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/neuro_load_widget_info"/>
</receiver>
```

#### c) Widget Info XML (`res/xml/neuro_load_widget_info.xml`)

```xml
<appwidget-provider
    android:minWidth="250dp"
    android:minHeight="80dp"
    android:updatePeriodMillis="1800000"
    android:initialLayout="@layout/glance_default_loading_layout"
    android:widgetCategory="home_screen"
    android:resizeMode="none"/>
```

Note: `updatePeriodMillis` is 30 minutes — Android limits background widget updates. The live timer update during an active session is handled by the foreground service sending a `WorkManager` one-time work request each minute to update the widget's `GlanceState` (see below).

#### d) Flutter → Widget Bridge

The `SessionNotifier` sends data to the widget via a `MethodChannel` each time the session state changes:

```dart
// widget_update_service.dart (new)
class WidgetUpdateService {
  static const _channel = MethodChannel('neuroload/widget');

  static Future<void> update({
    required bool isActive,
    required int elapsedSeconds,
    required String category,
    required String subCategory,
  }) async {
    await _channel.invokeMethod('updateWidget', {
      'isActive': isActive,
      'elapsedSeconds': elapsedSeconds,
      'category': category,
      'subCategory': subCategory,
    });
  }

  static Future<void> clear() async {
    await _channel.invokeMethod('clearWidget');
  }
}
```

This is called from `SessionNotifier.tick()` every 60 ticks (same cadence as the notification update), from `startSession()`, and from `finishSession()`.

The Kotlin `MethodCallHandler` in `MainActivity.kt` receives these calls and updates the `GlanceState`:

```kotlin
GlanceAppWidgetManager(context)
    .getGlanceIds(NeuroLoadWidget::class.java)
    .forEach { id ->
        updateAppWidgetState(context, id) { prefs ->
            prefs[booleanPreferencesKey("session_active")] = call.argument("isActive")!!
            prefs[intPreferencesKey("elapsed_seconds")] = call.argument("elapsedSeconds")!!
            prefs[stringPreferencesKey("category")] = call.argument("category")!!
        }
        NeuroLoadWidget().update(context, id)
    }
```

#### e) Deeplink Tap Handling

Tapping the idle widget's "Start Session" button opens the app directly to the Setup screen:

```kotlin
// In IdleWidget composable
actionStartActivity<MainActivity>(
    actionParametersOf(
        ActionParameters.Key<String>("deeplink") to "neuroload://setup"
    )
)
```

Tapping the "Distracted" button on the active widget fires the same pattern as the notification action: it sends a broadcast that calls `addLap()` without opening the app.

---

### iOS — WidgetKit Extension

iOS home screen widgets use **WidgetKit** (iOS 14+) with SwiftUI, similar to the Live Activities extension from FEATURE-01 but as a separate extension target.

**Required additions:**

#### a) New Widget Extension Target

A new `NeuroLoadWidget` extension target is created in Xcode (or via `flutter_widgetkit` package). This adds a `NeuroLoadWidget.swift` file with:

```swift
struct NeuroLoadWidget: Widget {
    let kind: String = "NeuroLoadWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SessionProvider()) { entry in
            NeuroLoadWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("NeuroLoad")
        .description("Your focus session at a glance.")
        .supportedFamilies([.systemMedium])
    }
}
```

#### b) App Groups (Shared Data)

Flutter writes session state to an **App Group** shared container so the widget extension can read it:

```dart
// Using shared_preferences with App Group (flutter_appauth or home_widget package)
HomeWidget.saveWidgetData<bool>('session_active', true);
HomeWidget.saveWidgetData<int>('elapsed_seconds', elapsed.inSeconds);
HomeWidget.saveWidgetData<String>('category', category);
HomeWidget.updateWidget(name: 'NeuroLoadWidgetProvider');
```

The widget Swift code reads from the same App Group key-value store:

```swift
struct SessionEntry: TimelineEntry {
    let date: Date
    let isActive: Bool
    let elapsedSeconds: Int
    let category: String
}

struct SessionProvider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<SessionEntry>) -> Void) {
        let userDefaults = UserDefaults(suiteName: "group.com.neuroload.app")
        let isActive = userDefaults?.bool(forKey: "session_active") ?? false
        let elapsed = userDefaults?.integer(forKey: "elapsed_seconds") ?? 0
        let category = userDefaults?.string(forKey: "category") ?? ""

        let entry = SessionEntry(date: Date(), isActive: isActive, elapsedSeconds: elapsed, category: category)
        // Refresh every minute when active, every 30 minutes when idle
        let nextUpdate = Date().addingTimeInterval(isActive ? 60 : 1800)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}
```

#### c) Recommended Package

**`home_widget`** Flutter package handles App Group data sharing, widget update triggering, and deeplink handling between Flutter and both iOS/Android widgets in one clean API.

```yaml
# pubspec.yaml
home_widget: ^0.4.0
```

#### d) Deeplink Tap Handling (iOS)

Tapping the idle widget opens the app via a URL scheme:

```swift
// In NeuroLoadWidgetEntryView body
Link(destination: URL(string: "neuroload://setup")!) {
    IdleContent()
}
```

Tapping "Distracted" on the active widget:

```swift
Link(destination: URL(string: "neuroload://distracted")!) {
    DistractedButton()
}
```

The app's URL scheme handler (already being built for FEATURE-01) processes `neuroload://distracted` and calls `addLap()`.

---

## Widget Visual Design

The widget must look like it belongs to NeuroLoad — not like a generic productivity widget. Key design principles:

**Typography:** The elapsed time on the active state uses the same `PlayfairDisplay` display font as the in-app timer. Large, confident numerals. Not a system font.

**Colour:** The widget background matches the user's selected theme (Obsidian Noir by default — near-black with teal accent). On iOS the widget reads the selected theme from the App Group shared defaults. This means if the user switches to Ash Light, the widget also switches.

**Idle state:** Minimal. The app name at top-left in very small teal label text. A single rounded "Start Session" button centred. Below it, in the smallest readable size, the last-session line if data exists. No decorative elements. The restraint is intentional.

**Active state:** The elapsed time is the dominant element — it should be the thing your eye goes to first. Category label above it in small all-caps teal. Distracted button is small, outlined, bottom-right. Not prominent — you shouldn't feel like you're invited to tap it.

**No shadows, gradients, or decorative icons.** The widget should look like it was cut from the same cloth as the rest of the app.

---

## What Happens When the User Adds the Widget

The user long-presses their home screen → taps the + icon → searches "NeuroLoad" → selects the medium widget → places it.

On first add, if no session has ever been run, the idle state shows:
- "NEUROLOAD"
- "Start Session" button
- Sub-text: "Your first session is waiting."

No permissions are required to add or display the widget. The "Distracted" action tap deeplinks into the running app (or opens it if backgrounded), which requires no additional permissions beyond what the app already has.

---

## Acceptance Criteria

- [ ] Widget is available on iOS as a medium-size WidgetKit widget.
- [ ] Widget is available on Android as a 4×2 home screen App Widget.
- [ ] Idle state shows app name, "Start Session" CTA, and last session summary if available.
- [ ] Active state shows live elapsed time (updating every 60 seconds), category, and sub-category.
- [ ] Active state includes a "Distracted" button that logs a Phone distraction without opening the app.
- [ ] Tapping the idle widget's CTA opens the Setup screen directly (no splash/home screen intermediate).
- [ ] Widget background colour matches the user's selected theme.
- [ ] Widget elapsed timer and category update within 60 seconds of a session state change.
- [ ] Widget clears to idle state within 60 seconds of a session finishing.
- [ ] The `home_widget` package (or equivalent) is used to bridge Flutter state to the native widget layer.
- [ ] Widget renders correctly on all supported screen sizes (verified on at least: iPhone 14, iPhone SE, Pixel 6a, Samsung Galaxy A54).
- [ ] No additional permissions are required to display the widget.

---

## Dependencies

- Flutter package: `home_widget` (^0.4.0) — handles App Group data sharing + update triggers
- Kotlin Glance library (`androidx.glance:glance-appwidget`) — Android widget UI
- SwiftUI + WidgetKit — iOS widget UI (system framework, no external dependency)
- URL scheme handler (shared with FEATURE-01 deeplink handling)
- `WidgetUpdateService` (new Dart class, ~50 lines)
- Existing: `SessionNotifier.tick()` — already fires every 60 seconds, just needs one more call

---

## Out of Scope for v1

- Small (2×1) or large (4×4) widget variants.
- Interactive text input from the widget (e.g., typing a session intent).
- Widget analytics (tracking how many sessions were started from widget vs. app).
- Complication support for Apple Watch.
- Android lock screen widget (separate from home screen, different API).

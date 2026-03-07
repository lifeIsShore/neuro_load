# BUG-13 — Font Selection: Typeface Does Not Apply + Bottom Sheet Not Scrollable

**Status:** Open  
**Priority:** Medium  
**Reported:** 2026-03-07  
**Module:** Settings → Font Picker / `settings_screen.dart` → `_showFontPicker()`  
**Related:** No existing ticket

---

## Problem Summary

The font picker in Settings has **two separate bugs** that together make the font feature almost non-functional:

### Bug 13a — Selected Font Is Not Applied to the App's Text
When a user selects a font from the picker (e.g., "Merriweather"), the settings tile subtitle updates to show the new font name, and `SettingsNotifier.setFont()` correctly saves the value to SharedPreferences. However, **the visual appearance of text throughout the app does not change** — everything continues to render in the default font.

**Root cause hypothesis:** The app theme (`AppTheme`) reads `fontFamily` once at startup (or not at all), and does not rebuild when `settingsProvider.fontFamily` changes. The `MaterialApp`/`ThemeData` is not watching the settings provider, so the new font is persisted but never applied to the running `TextTheme`.

### Bug 13b — Font Picker Bottom Sheet Cannot Be Scrolled
The `_showFontPicker()` method renders a `ModalBottomSheet` whose content is a `Column` with `mainAxisSize: MainAxisSize.min`. On devices with smaller screen heights (or when the soft keyboard reduces available space), **only the font options visible in the initial render are reachable**. The sheet does not scroll — there is no `SingleChildScrollView`, no `ListView`, and no `DraggableScrollableSheet` wrapping the content.

Users on small-screen devices or with large system font sizes cannot see or tap any font below the fold.

---

## Expected Behaviour

### Bug 13a — Font Applied Immediately
- When the user selects a font and the picker closes, all text in the app (headlines, body, labels, buttons) immediately re-renders in the newly selected font.
- No app restart required.
- The change persists across app restarts (already works — just the live apply is broken).

### Bug 13b — Scrollable Font Picker
- The font picker bottom sheet is fully scrollable on all screen sizes.
- All 5 (or more) font options are reachable by scrolling regardless of device height.
- The sheet can be dragged down to dismiss (standard bottom sheet behaviour).
- A drag handle indicator is visible at the top of the sheet.

---

## Root Cause

**Bug 13a — `app_theme.dart` / `main.dart`:**

```dart
// Likely in main.dart or a root widget — AppTheme.build() is called once:
MaterialApp(
  theme: AppTheme.light(),   // ← fontFamily not driven by settingsProvider
  ...
)
```

The fix requires the root widget to `watch(settingsProvider)` and pass `fontFamily` into `ThemeData(fontFamily: ...)` so that a change triggers a full theme rebuild.

**Bug 13b — `settings_screen.dart` → `_showFontPicker()`:**

```dart
// Current (broken):
builder: (ctx) => StatefulBuilder(
  builder: (ctx, setSheet) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,  // ← fixed height, no scroll
      children: [ ... font list items ... ],
    ),
  ),
),

// Should be (fixed):
isScrollControlled: true,   // allow the sheet to be taller
builder: (ctx) => DraggableScrollableSheet(
  initialChildSize: 0.5,
  minChildSize: 0.3,
  maxChildSize: 0.85,
  builder: (ctx, scrollController) => SingleChildScrollView(
    controller: scrollController,
    child: Column( ... ),
  ),
),
```

---

## Acceptance Criteria

### 13a
- [ ] Selecting a font in the picker immediately changes the rendered typeface across all screens without restarting the app.
- [ ] The `MaterialApp` theme is rebuilt reactively when `settingsProvider.fontFamily` changes.
- [ ] Verified on: Inter (default), Roboto, Merriweather, JetBrains Mono, Atkinson Hyperlegible.

### 13b
- [ ] The font picker bottom sheet scrolls smoothly when content exceeds the visible area.
- [ ] All font options are reachable on a device with a 5-inch / 360×640 dp screen.
- [ ] The sheet displays a visible drag handle and can be dismissed by dragging down.
- [ ] `isScrollControlled: true` is set on `showModalBottomSheet`.

---

## Steps to Reproduce

### 13a
1. Open Settings.
2. Tap **Font** → select **Merriweather**.
3. Observe: the Settings tile subtitle changes to "Merriweather".
4. Navigate to Dashboard or Timer screen.
5. **Expected:** all text is rendered in Merriweather serif font.  
   **Actual:** text remains in Inter (or system default).

### 13b
1. On a device or simulator with screen height ≤ 750 dp (e.g., iPhone SE, Pixel 4a).
2. Open Settings → tap **Font**.
3. Attempt to scroll down inside the font picker sheet.
4. **Expected:** sheet scrolls to reveal all font options.  
   **Actual:** sheet does not scroll; fonts below the fold are unreachable.

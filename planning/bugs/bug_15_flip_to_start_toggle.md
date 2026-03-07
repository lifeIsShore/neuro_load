# BUG-15 — "Flip to Start" Toggle in Setup: No Enforcement During Session

**Status:** Fixed  
**Priority:** High  
**Reported:** 2026-03-07  
**Module:** `setup_screen.dart`, `sensor_provider.dart`, `session_provider.dart`  
**Related:** BUG-14 (Oversensitivity), BUG-10 (Auto-Distraction)

---

## Problem Summary

The **Setup screen** (`setup_screen.dart`) currently has a hardcoded bottom hint:  
*"Or flip phone face-down to start automatically."*  

There is no toggle for the user to opt in or out of flip-to-start behaviour. Regardless of user intent, the `faceDownStartProvider` always watches the accelerometer during setup and fires `_startSession()` if the phone is placed face-down.

More critically: **once a session is running, the "flip distraction" system is always active.** There is no way for a user to say "I prefer to log distractions manually — do not auto-log every time I flip my phone." If a user intentionally places their phone face-up on a desk while working (not distracted), the system logs it as a distraction.

### The Specific Conflict Described

When the **Flip to Start** option is **enabled**:
- The user flips the phone face-down → session starts.
- During the session, flipping it back face-up → correctly logs a distraction.

When the **Flip to Start** option is **disabled**:
- The user starts the session manually via the START SESSION button.
- The user may flip or move their phone during the session — but since they chose not to use flip-based interaction, the app should **not** auto-log their phone movements as distractions.
- Currently, the app auto-logs phone distraction regardless, because the sensor is always active and the toggle does not exist.

---

## Expected Behaviour

### In Setup Screen
- A **checkbox or toggle** labelled **"Flip to Start"** (or "Use phone flip") is presented in the Setup screen, below the START SESSION button, replacing the current static hint text.
- Default state: **enabled** (matches current behaviour for new users).
- The selection is persisted to `SharedPreferences` (key: `session_flip_to_start`) and loaded on next open.

### During Session (Enforced by the Toggle)

| Flip to Start | Effect on auto-distraction during session |
|---|---|
| **Enabled** | Flipping phone face-up during a session auto-logs a Phone distraction (current behaviour, Bug 14 debounce still applies). |
| **Disabled** | Sensor is NOT watched for distraction during the session. Phone movements do not auto-log anything. User logs distractions manually via the DISTRACTED button only. |

### Additional Guardrail When Enabled
When **Flip to Start is enabled** and the user tries to flip the phone face-up during an active session, a brief **non-blocking in-session toast/banner** appears:  
*"📱 Phone flip detected — distraction logged."*  
This confirms the auto-log without interrupting the session.

---

## Root Cause

`sensor_provider.dart` → `FaceDownNotifier._onEvent()` unconditionally calls `addLap()` whenever `phase == SessionPhase.active` and the phone transitions to face-up. There is no feature flag, no provider state, and no user-facing toggle that controls this behaviour.

`setup_screen.dart` shows a static text hint with no interactive element tied to `faceDownStartProvider`.

---

## Required Changes

### 1. Add `flipToStartEnabled` to `AppSettings`
```dart
// session_provider.dart → AppSettings
class AppSettings {
  ...
  final bool flipToStartEnabled;  // NEW

  const AppSettings({
    ...
    this.flipToStartEnabled = true,
  });
}
```
With corresponding `toggleFlipToStart()` in `SettingsNotifier` and `SharedPreferences` persistence.

### 2. Add Checkbox to `SetupScreen`
Replace the static hint text with an interactive checkbox:
```dart
Row(
  children: [
    Checkbox(
      value: ref.watch(settingsProvider).flipToStartEnabled,
      onChanged: (_) => ref.read(settingsProvider.notifier).toggleFlipToStart(),
    ),
    const SizedBox(width: 8),
    Text('Flip phone face-down to start'),
  ],
)
```

### 3. Gate `faceDownStartProvider` on the Toggle
In `setup_screen.dart`:
```dart
ref.listen(faceDownStartProvider, (previous, next) {
  final flipEnabled = ref.read(settingsProvider).flipToStartEnabled;
  if (next == true && canStart && flipEnabled) {  // ← gate added
    _startSession();
  }
});
```

### 4. Gate Auto-Distraction in `sensor_provider.dart`
```dart
void _logPhoneDistraction() {
  final flipEnabled = _ref.read(settingsProvider).flipToStartEnabled;
  if (!flipEnabled) return;   // ← user opted out of flip-based interaction
  ...
}
```

---

## Acceptance Criteria

- [ ] A **"Flip to Start"** checkbox is visible in the Setup screen.
- [ ] When unchecked, flipping the phone face-down on the Setup screen does NOT start the session.
- [ ] When unchecked, no auto-distraction laps are logged during a session due to phone movements.
- [ ] When checked (default), all existing flip-to-start and flip-distraction behaviour works as before (with BUG-14 fixes applied).
- [ ] The toggle state persists across app restarts.
- [ ] A brief in-session confirmation banner is shown when a distraction IS auto-logged via flip.
- [ ] The setting is also accessible from Settings screen under a new "Session Behaviour" section (or similar).

---

## Edge Cases to Handle

- **User enables Flip to Start mid-session:** Not possible — Setup screen is pre-session only. The toggle takes effect on the next session.
- **User has a bad calibration + Flip to Start enabled:** See BUG-12. Bad calibration can cause false positives. BUG-15 fix + BUG-14 fix + BUG-12 fix together form a complete solution.
- **Flip to Start disabled but user accidentally starts session face-down:** The START SESSION button still works; the face-down position is simply ignored.

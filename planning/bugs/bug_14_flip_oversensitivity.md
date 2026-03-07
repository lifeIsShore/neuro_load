# BUG-14 — Phone Flip Oversensitivity: Multiple Distraction Logs from a Single Flip Event

**Status:** Fixed  
**Priority:** Critical  
**Reported:** 2026-03-07  
**Module:** `sensor_provider.dart` → `FaceDownNotifier._onEvent()` / `session_provider.dart` → `SessionNotifier.addLap()`  
**Related:** BUG-12 (Calibration UX), BUG-10 (Auto-Distraction on Flip-Up)

---

## Problem Summary

The auto-distraction detection logic in `FaceDownNotifier._onEvent()` registers **multiple distraction lap entries for a single physical phone flip**, sometimes logging 3–6 entries within 1–2 seconds because:

1. **No debounce or cooldown exists.** Every accelerometer event that crosses the Z-axis threshold independently triggers a `addLap()` call. A single flip gesture produces dozens of crossing events as the phone oscillates through the threshold boundary.

2. **The threshold is too sensitive.** The current setup fires on any `z <= _zThreshold` crossing. Small desk vibrations, pocket jostles, or the user simply picking up the phone to look at the time all register as distractions, even though no intentional flip occurred.

The compound result is that after one distraction, the session log shows 4–8 identical "auto: phone flipped up" entries within a 1-second window, which corrupts focus density scores, quality scores, and the lap feed display.

---

## Expected Behaviour

1. **One physical flip = exactly one distraction log entry.**
2. **Micro-movements and vibrations are filtered out.** Picking up the phone, placing it down on a surface, or desk vibrations should not trigger a distraction unless a deliberate, sustained flip occurred.
3. **After a distraction is logged, the system cannot log another phone-flip distraction for at least 6 seconds.** This cooldown matches the minimum credible time for a human to flip, put down, and re-flip a phone.
4. **A minimum hold duration must be exceeded before the flip is counted.** The phone must be above the face-up threshold (or below the face-down threshold) continuously for at least 1.0 second before the state transition is registered.

---

## Root Cause

In `sensor_provider.dart`, the `_onEvent` handler fires on every accelerometer sample (every 200 ms during active sessions). The current logic:

```dart
void _onEvent(AccelerometerEvent e) {
  final nowDown = e.z <= _zThreshold;

  if (nowDown && !_isDown) {
    _isDown = true;
    _holdTimer = Timer(_holdDuration, () {
      if (_isDown) state = true;   // ← only face-down (start trigger) is debounced
    });
  } else if (!nowDown && _isDown) {
    // Bug 14: NO hold timer, NO cooldown — fires instantly
    _isDown = false;
    _holdTimer?.cancel();

    final phase = _ref.read(sessionProvider).phase;
    if (phase == SessionPhase.active) {
      _ref.read(sessionProvider.notifier).addLap(   // ← called raw, no rate-limit
        trigger: DistractionTrigger.phone,
        note: 'auto: phone flipped up',
      );
    }
  }
}
```

The face-down-to-face-up transition (`!nowDown && _isDown`) has:
- **No hold timer** — it fires the moment a single sample crosses back above the threshold.
- **No cooldown** — repeated crossings from oscillation each independently call `addLap()`.

---

## Proposed Fix

### 1. Add a Hold Timer for Face-Up Detection
The phone must be in face-up orientation for ≥ **800 ms** before the distraction is logged. This is symmetric with the existing `_holdDuration` used for face-down detection on session start.

```dart
Timer? _faceUpHoldTimer;

} else if (!nowDown && _isDown) {
  _isDown = false;
  _holdTimer?.cancel();

  // Start a hold timer — only log if phone stays face-up
  _faceUpHoldTimer?.cancel();
  _faceUpHoldTimer = Timer(const Duration(milliseconds: 800), () {
    _logPhoneDistraction();
  });
}

// If the phone goes back face-down before 800ms, cancel the pending log
if (nowDown && !_isDown) {
  _faceUpHoldTimer?.cancel();
  ...
}
```

### 2. Add a Per-Distraction Cooldown
After a phone distraction is successfully logged, no additional phone distraction can be logged for **6 seconds**:

```dart
DateTime? _lastPhoneDistractionAt;
static const _distractionCooldown = Duration(seconds: 6);

void _logPhoneDistraction() {
  final now = DateTime.now();
  if (_lastPhoneDistractionAt != null &&
      now.difference(_lastPhoneDistractionAt!) < _distractionCooldown) {
    return; // still in cooldown
  }
  _lastPhoneDistractionAt = now;

  final phase = _ref.read(sessionProvider).phase;
  if (phase == SessionPhase.active) {
    _ref.read(sessionProvider.notifier).addLap(
      trigger: DistractionTrigger.phone,
      note: 'auto: phone flipped up',
    );
  }
}
```

### 3. Raise the Threshold Angle for Distraction Detection
The distraction should only fire when the phone is clearly face-up (screen pointing upward), not just "less face-down". Introduce a separate **face-up threshold** that is a few units above the face-down threshold:

```dart
// Example: face-down at z <= -8.0, face-up only when z >= -3.0
// This gap prevents oscillation from toggling the state repeatedly
static const double _faceUpThreshold = -3.0; // tunable, saved separately

void _onEvent(AccelerometerEvent e) {
  final nowDown = e.z <= _zThreshold;
  final nowUp   = e.z >= _faceUpThreshold;   // ← hysteresis gap

  if (nowDown && !_isDown) { ... }
  else if (nowUp && _isDown) { ... }    // only trigger on clear face-up
}
```

This **hysteresis gap** between face-down threshold (~−8) and face-up threshold (~−3) means the phone must travel all the way to a clearly face-up orientation before the state flips.

---

## Acceptance Criteria

- [ ] A single phone flip during an active session logs **exactly one** distraction entry.
- [ ] No distraction is logged if the phone is flipped and then immediately flipped back within 800 ms.
- [ ] No second phone-flip distraction can be logged within 6 seconds of the previous one.
- [ ] Small desk vibrations (tested by tapping the table while phone lies flat) do not trigger distractions.
- [ ] Picking the phone up from a table and setting it back down (screen up) in under 1 second does not trigger a distraction.
- [ ] The hysteresis gap between face-down and face-up thresholds prevents oscillation logs.
- [ ] Existing session start (face-down hold) behaviour is not affected.
- [ ] All cooldown timers are correctly cancelled on `dispose()` to prevent memory leaks.

---

## Steps to Reproduce (Current Behaviour)

1. Start a session.
2. Pick up the phone so the screen faces upward.
3. Watch the lap feed on the timer screen.
4. **Expected:** 1 distraction log entry ("📱 Phone").  
   **Actual:** 3–8 identical "📱 Phone" entries appear within 1–2 seconds.
5. Tap the DISTRACTED button to open the distraction modal and observe the inflated lap count.

---

## Impact

- **Quality Score** is artificially deflated — each false extra lap subtracts from focus density.
- **Session 1RM** computation (`sessionOneRM`) is broken by spurious timestamps inserted between real laps.
- **Lap Feed** on the timer screen becomes cluttered and confusing.
- User trust in data accuracy is severely damaged.

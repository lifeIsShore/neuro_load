# BUG-12 — Phone Flip Calibration: Static Timer Instead of Guided Motion Flow

**Status:** Fixed  
**Priority:** High  
**Reported:** 2026-03-07  
**Module:** Onboarding → Calibration Screen / `sensor_provider.dart`  
**Related:** BUG-08 (Flip-to-Start Calibration Instructions — partially overlaps but this ticket focuses on the *interaction model*, not just copy)

---

## Problem Summary

The current phone-flip calibration screen presents a **fixed timer countdown** to guide the user through placing the phone face-down. This approach has two critical UX failures:

1. **It does not adapt to the user's actual motion.** If the user flips the phone too slowly, too early, or not at all, the timer still runs and the calibration still "completes" — often with a bad threshold value.
2. **It gives no real-time spatial feedback.** The user cannot see which direction they are moving the phone or whether the app is detecting it correctly, so they have no way to correct themselves mid-calibration.

The result is that many users finish calibration with a threshold that does not match their device posture, causing flip-to-start and auto-distraction detection to misbehave throughout the app.

---

## Expected Behaviour (After Fix)

### Phase 1 — Instruction
- A clear instruction card is shown:  
  *"Let's calibrate your phone. Start by holding it flat in front of you, screen facing you."*
- A simple 3D phone illustration (or Lottie animation) shows the starting orientation.
- No timer is running yet. The user proceeds when ready by tapping **"I'm Ready"**.

### Phase 2 — Live Water-Level Indicator (the core change)
- Once calibration starts, a **visual "water level" or bubble-level widget** is displayed — think a circular or rectangular level gauge where a bubble or liquid indicator moves in real time based on the accelerometer's X / Y / Z axes.
- As the user tilts and rotates their phone, the bubble moves inside the gauge, giving instant spatial feedback.
- Instructional text updates dynamically:
  - *"Tilt your phone to the right…"*
  - *"Almost there — a little more…"*
  - *"Now flip it face-down — keep going…"*
- The sensor readings are captured **at the moment the device reaches the correct orientation**, not at the end of a fixed timer.

### Phase 3 — Confirmation Checkpoints
- The calibration requires the user to hit **3 orientation checkpoints** in sequence:
  1. **Screen up (flat)** — establishes the baseline "neutral" Z value.
  2. **Tilted 90° right** — establishes lateral sensitivity.
  3. **Screen down (face-down)** — captures the target flip threshold.
- Each checkpoint lights up with a green tick and a haptic pulse (medium impact) when successfully held for 800 ms.
- The water-level indicator shows a green "locked" state when a checkpoint is confirmed.
- The user **cannot proceed** to the next checkpoint unless the current one is confirmed.

### Phase 4 — Final Confirmation
- After all 3 checkpoints:
  - A summary screen shows the detected threshold values in human-readable form (e.g., *"Face-down detected at –9.2 m/s²"*).
  - A **"Test It Now"** button lets the user do a live flip test right there — if the app detects the flip within 2 seconds, it shows *"✓ Flip detected!"* with a strong haptic. If not, the user can recalibrate.
  - Only after a successful test (or explicit skip) is the threshold saved to `SharedPreferences` under `sensor_z_baseline`.

---

## Root Cause

In `sensor_provider.dart`, `_zThreshold` is loaded from `sensor_z_baseline` in SharedPreferences. The calibration screen sets this value based on a timer, not on actual confirmed sensor readings. The water-level interaction model and checkpoint system do not exist yet.

**Relevant code path:**
```
lib/providers/sensor_provider.dart
  └── FaceDownNotifier._loadThresholdThenSubscribe()
      └── prefs.getDouble('sensor_z_baseline')    ← written by calibration
lib/screens/onboarding/  ← calibration screen lives here (needs redesign)
```

---

## Acceptance Criteria

- [ ] Calibration screen shows a real-time visual level indicator driven by live `AccelerometerEvent` data.
- [ ] Indicator responds visually to device orientation changes with < 100 ms latency.
- [ ] Three orientation checkpoints must be hit and held for ≥ 800 ms before calibration completes.
- [ ] Each confirmed checkpoint triggers a medium haptic + green visual tick.
- [ ] A live test step exists: user flips phone and app confirms detection before saving.
- [ ] `sensor_z_baseline` is only written after a successful live test (or explicit "Skip Test" tap).
- [ ] No timer countdown exists anywhere in this flow.
- [ ] Calibration is re-enterable from Settings if the user wants to recalibrate later.

---

## Out of Scope

- Changing the actual flip detection logic in `FaceDownNotifier._onEvent()` — that is covered by BUG-14.
- Changing what happens *after* a flip is detected during a session.

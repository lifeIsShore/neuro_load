# NeuroLoad — Phase 2 Development Guide

> **Target:** Post-MVP Scale & Advanced Features
> **Prerequisites:** The Core Training Loop, Local Analytics, Cloud Sync, and Paywall Gate (MVP) are fully complete.

---

## 1. The Immediate "Pre-Launch" Gap

Before initiating any marketing or taking real users, the following **must** be completed bridging from MVP to Phase 2:

### 🔴 Stripe Integration (MVP.003.003)
Currently, the Paywall "UNLOCK" button is a stub. Any 8-character voucher code bypasses it.
- **Action:** Create a Supabase Edge Function to create Stripe Checkout Sessions.
- **Action:** Integrate `url_launcher` to open the checkout sheet.
- **Action:** Set up a Stripe Webhook to update the Supabase `users` table upon successful payment.
- **Action:** Update the Flutter app to verify payment via Supabase RPC rather than the local voucher stub.

---

## 2. Phase 2 Features (The Next Horizon)

### 🔮 US 9.3 — Circadian Rhythm Analysis ("Prime Time")
- **Goal:** Analyze the user's focus density and 1RMs against the hour of the day to detect their peak cognitive hours.
- **Implementation:** Create a new chart in the Dashboard plotting `time_of_day` against `average_quality_score`.

### ⏱️ US 9.4 — Ghost Intent Reminder
- **Goal:** When the user hits the "Distracted" button, flash their pre-session "Intent" statement on the screen to pull them back into focus.
- **Implementation:** Pass the `intent` string from `SetupScreen` into `SessionState`. Update `DistractionModal` to prominently display: *"You were trying to: [Intent]"*.

### 📱 US 7.4 — Live Activities (iOS Only)
- **Goal:** Mirror the Android Foreground Service functionality on iOS by showing a live timer on the Dynamic Island / Lock Screen.
- **Implementation:** Integrate `live_activities` package. Write Swift bridge code for updating the timer state from Flutter.

---

## 3. Phase 3 & 4 Preview (Long-Term Vision)

- **Smart Coach ML (ARIMA):** Move from the rule-based coach to a local basic ML model for trend forecasting.
- **Next.js B2B Web Portal:** For teams to aggregate anonymous focus metrics.
- **Study Lounges & Battles:** Real-time pairing using Supabase Presence.
- **The "Soundscape" Engine:** Built-in generative audio (binaural beats).

---

## 4. UI/UX Polish Backlog

While the current dark-mode/teal aesthetic is highly functional and uses a consistent design token system, consider the following polish items before scaling:
- **Animations:** Add `Hero` transitions between the Dashboard cards and fullscreen charts.
- **Micro-interactions:** Add particle effects or a success confetti when beating an all-time 1RM.
- **Typography:** Implement US 9.8 (Dyslexia-Friendly OpenDyslexic font toggle).

---

## 5. QA Testing Protocol

To test the current build on a physical Android device:
1. Enable **Developer Options** and **USB Debugging** on the Android device.
2. Connect via USB.
3. Run `flutter devices` to ensure it is recognised.
4. Run: `flutter run -d <device_id> --release` (Testing the Foreground Service and Sensors is most accurate in a release build).
5. **Key flows to test:**
   - Complete physical Face-Down calibration in Onboarding.
   - Run a session, put the app in the background, ensure the notification appears and the timer continues ticking.
   - Enter a bogus 8-character code in the Paywall to verify the unlock flow works.

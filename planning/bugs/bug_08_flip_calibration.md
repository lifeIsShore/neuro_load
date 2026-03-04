# 8. Flip-to-Start Calibration & Instructions

## Description
As a user, I want clear instructions and a test step for the phone-flip calibration, so that the app reliably detects when I turn my phone face down to start a session.
**Problem Context:** The sensor calibration step exists but is confusing and users are skipping it or setting bad values, causing hardware detection to fail.

## Acceptance Criteria
- [ ] The calibration UI contains visual animations or clear text explaining *how* to place the phone flat on the table, face down.
- [ ] The step includes a "Testing Phase: Flip your phone now" which confirms successful calibration with a green checkmark or haptic feedback.
- [ ] Only upon successful test can the user proceed.

## Resolution / Solution Method
- Redesign the `CalibrationScreen` in the onboarding flow.
- Add a live listening test that visually reacts when the correct "face down" accelerometer/gyro threshold is met.
- Store the verified threshold bounds securely.

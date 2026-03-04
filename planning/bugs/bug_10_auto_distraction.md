# 10. Auto-Distraction on Flip Up

## Description
As a user, if I pick up my phone and flip it face-up during a session, I want the app to automatically mark me as "distracted", so that strict focus rules are enforced without me manually logging it.
**Problem Context:** Users are checking messages but keeping the timer running.

## Acceptance Criteria
- [ ] While a session is active, if the device accelerometer detects the phone turning face-up past a certain threshold, a distraction is instantly logged.
- [ ] The screen updates to show a distraction notification or penalty.
- [ ] Flipping it back face-down resumes the standard tracking.

## Resolution / Solution Method
- Keep an active listener on the device sensors (`sensors_plus`) during the `FaceDown` session mode.
- Define a threshold angle (e.g., > 135 degrees from flat-down).
- Trigger the `addDistraction()` method mathematically the moment the threshold is breached.

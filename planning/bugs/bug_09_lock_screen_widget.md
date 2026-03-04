# 9. Lock Screen Widget with Distraction Logging

## Description
As a user, when my phone screen turns off to save battery, I want to see a live-updating Lock Screen widget with my remaining focus time and a "Mark Distraction" button, so that I don't have to unlock my phone to manage my session.
**Problem Context:** App loses visibility when device locks. Users need a quick way to log distractions purely from the lock screen.

## Acceptance Criteria
- [ ] A Live Activity (iOS) / Foreground Service Notification (Android) appears when the screen locks during an active session.
- [ ] The widget clearly displays the live session timer.
- [ ] The widget includes an actionable button: "I got distracted", which logs a distraction point without opening the app.

## Resolution / Solution Method
- **iOS:** Implement ActivityKit for Live Activities to show the timer and interactive buttons.
- **Android:** Implement a deep-linked Action Button in the ongoing foreground service notification.
- Connect these background actions to the core session manager.

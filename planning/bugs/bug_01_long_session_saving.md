# 1. Long Session Saving Failure

## Description
As a user, I want my long focus sessions to be explicitly saved when I click "finish", so that I don't lose the progress of my longest and most important sessions.
**Problem Context:** Sessions of extended lengths fail to trigger the save action, or the "finish" state is not handled properly, resulting in data loss.

## Acceptance Criteria
- [ ] A session of any length (> 2 hours) saves successfully to the local database.
- [ ] The "Finish" button reliably terminates the session and triggers the save mechanism.
- [ ] In case of a crash or app kill during a long session, the session time up to that point is recoverable or automatically saved.

## Resolution / Solution Method
- Investigate the `finish` session trigger logic in the timer/session controller.
- Check if integer overflow or background execution limits are killing long sessions.
- Implement periodic auto-saving to local storage during long sessions.

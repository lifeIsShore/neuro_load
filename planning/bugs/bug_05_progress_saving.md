# 5. Sporadic Progress Saving Bug

## Description
As a user, I want my progress to be reliably saved 100% of the time, so that I can trust the app to track my habits.
**Problem Context:** Some sessions randomly fail to persist to the database after completion.

## Acceptance Criteria
- [ ] All completed sessions reliably appear in the history/statistics view immediately after finishing.
- [ ] If a database write fails, the app queues it for a retry rather than failing silently.

## Resolution / Solution Method
- Add robust error handling and logging to the database write operations (Supabase/SQLite).
- Verify if the issue stems from background processing being killed prematurely on iOS/Android.
- Implement a local queue/cache for offline or failed saves to sync later.

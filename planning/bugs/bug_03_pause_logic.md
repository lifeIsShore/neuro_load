# 3. Pause Logic Too Generous

## Description
As a user, I want the pause functionality to strictly track my break times, so that the app accurately calculates my true focused time vs. distracted/paused time.
**Problem Context:** The current implementation of "pause" is giving the user too much leeway, skewing the focus analytics.

## Acceptance Criteria
- [ ] Pauses have a strict, tracked limit that accurately subtracts from the overall focus score.
- [ ] Exceeding a reasonable pause duration automatically terminates the session or heavily deducts quality score.

## Resolution / Solution Method
- Redefine the algorithmic weight of a "pause" state in the timer sequence.
- Add strict thresholds for accumulated pause times per session.
- Ensure the timer pauses both the session display and the internal "focused time" accumulator.

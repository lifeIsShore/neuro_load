# 2. Inconsistent Quality Score Calculation

## Description
As a user, I want the session quality score to accurately reflect my current session's performance, so that quick/failed sessions aren't artificially boosted by previous good sessions.
**Problem Context:** The algorithm is carrying over state or heavily weighting previous session scores, leading to 1-minute sessions receiving 100/100 quality scores.

## Acceptance Criteria
- [ ] The quality score calculation is strictly isolated to the metrics of the *current* session.
- [ ] A short session (e.g., < 5 minutes) without meeting focus criteria does not receive a high score.
- [ ] The score algorithm transparently weights session length vs. distractions.

## Resolution / Solution Method
- Audit the `QualityScore` calculator algorithm.
- Ensure state variables tracking previous session performance are reset at the start of a new session.
- Adjust the algorithm curve to penalize extremely short sessions appropriately.

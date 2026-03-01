# NeuroLoad: Enhanced User Stories v2.0
## Persona-Driven, MVP-Focused, Phase-Prioritized

**Document Purpose:** Actionable user stories for Sprint Planning  
**Scope:** MVP (Months 0-6) + Phase 2/3 Deferred  
**Format:** User Story + Acceptance Criteria + Tasks + Effort Estimate  

---

## HOW TO USE THIS DOCUMENT

### Story Numbering Convention

```
[PHASE].[EPIC].[STORY_ID] — [Title]

Example:
MVP.001.001 — Start a Focus Session (Manual Button)
Phase2.003.005 — Generate Tax Invoice (Delayed)

Phases:
├─ MVP: Months 0-6 (MUST SHIP)
├─ Phase2: Months 7-12 (High-Value, Deferred)
└─ Phase3: Months 13+ (Strategic, Future)
```

### Effort Estimation Scale

```
🟢 Small (1-3 days): <40 story points
🟡 Medium (1-2 weeks): 40-80 story points
🔴 Large (2-4 weeks): 80-160 story points
🟣 Huge (4+ weeks): >160 story points

SOLO DEVELOPER CAPACITY: ~40-50 story points/week
```

### Success Criteria for Each Story

Every story must answer:
1. **What's the user outcome?** (not technical implementation)
2. **Why does it matter?** (business value)
3. **How do we know it works?** (measurable acceptance criteria)

---

# EPIC 0: ONBOARDING & CORE PHILOSOPHY
## (The 4-Step Indoctrination — MVP Only)

### MVP.000.001 — The Manifesto Screen
**Title:** New User Sees the "Popcorn Brain" Manifesto on First Launch  
**Persona:** All (Elias, Aisha, Marcus)  
**Why:** Sets the tone; frames distractions as data, not shame. Critical for positioning.

**User Story:**
> As a new user, I want to read a one-screen, emotionally resonant introduction to the "Popcorn Brain" problem so I understand the app's core philosophy before using it.

**Acceptance Criteria:**
- [ ] Manifesto screen appears immediately after first app open.
- [ ] Text includes: the problem, the solution (progressive overload), and the promise (no shame).
- [ ] User must scroll to bottom before "Accept" button activates (ensures they read it).
- [ ] Typewriter text effect (optional but nice for UX).
- [ ] Takes <60 seconds to read.

**Effort:** 🟢 Small (3 days)  
**Dependencies:** None (first screen)

**Tasks:**
- [ ] Design Manifesto text (copy-writing; ~200 words).
- [ ] Build Flutter screen with scroll listener (unlock "Accept" button).
- [ ] Add typewriter animation (optional; use `text_animation` package or custom AnimatedBuilder).
- [ ] Test on iPad + small phones (ensure text scales well).

---

### MVP.000.002 — Lap Mechanic Tutorial
**Title:** New User Learns That Distractions Are "Reps," Not Failures  
**Persona:** All  
**Why:** Reframes the mental model. Critical for reducing shame/churn.

**User Story:**
> As a new user, I want a visual tutorial showing how the "Lap" trigger works (logging a distraction without stopping the timer) so I understand that this app celebrates resilience, not perfection.

**Acceptance Criteria:**
- [ ] Screen shows an animated mock-up of the Chronometer + "Distracted" button.
- [ ] User must **tap the mock "Distracted" button at least once** to proceed (interactive, not passive).
- [ ] Text explains: "Each distraction is a rep. You don't fail; you train."
- [ ] Haptic feedback on tap (same heavy "Thud" as real sessions).
- [ ] Animation loop if user doesn't interact within 10 seconds (subtle prompt).

**Effort:** 🟡 Medium (5 days)  
**Dependencies:** None

**Tasks:**
- [ ] Build interactive mock Chronometer widget.
- [ ] Implement tap listener → haptic feedback → page advance.
- [ ] Animate "Distracted" button press visually.
- [ ] Add 10-second "hint" animation (subtle pulse).

---

### MVP.000.003 — Sensor Calibration
**Title:** New User Calibrates Face-Down Trigger  
**Persona:** All (but especially Aisha; manual fallback for accessibility)  
**Why:** Baseline gyro/proximity values needed for reliable face-down detection.

**User Story:**
> As a new user, I want to place my phone face-down on a desk so the app learns my baseline gyro/proximity values and can reliably detect the face-down trigger later.

**Acceptance Criteria:**
- [ ] Screen prompts: "Place your phone face-down on your desk. I'll learn your device's baseline."
- [ ] App records 3 samples (1-2 seconds apart) of gyroscope X/Y/Z + proximity value.
- [ ] Haptic confirmation (ascending tone) when baseline is captured.
- [ ] User sees: "Baseline saved. Flip your phone back up to continue."
- [ ] Can be skipped via "Manual Start" fallback (accessibility).

**Effort:** 🟡 Medium (5 days)  
**Dependencies:** `sensors_plus` package (gyro + proximity)

**Tasks:**
- [ ] Read raw sensor data via `sensors_plus`.
- [ ] Implement 3-sample averaging logic (noise reduction).
- [ ] Store baseline values in `SharedPreferences` (calibration key).
- [ ] Test on iPhone + 2x Android devices (ensure consistency).

---

### MVP.000.004 — Pre-Flow Intent Statement Practice
**Title:** New User Writes Their First Intent Statement  
**Persona:** All  
**Why:** Establishes the "micro-contract" habit; helps refocus on distraction.

**User Story:**
> As a new user, I want to write a single sentence describing what I'm about to focus on (e.g., "Complete the Finance exam review") so I internalize the commitment before the timer starts.

**Acceptance Criteria:**
- [ ] Text input field; max 100 characters.
- [ ] User must enter at least 10 characters before proceeding.
- [ ] Example text shown as placeholder: "e.g., 'Complete the UI wireframes.'"
- [ ] "Next" button disabled until minimum length is reached.

**Effort:** 🟢 Small (2 days)  
**Dependencies:** None

**Tasks:**
- [ ] Build text input with character counter.
- [ ] Implement validation logic (min 10 chars).
- [ ] Store intent string in-memory (for session state).

---

### MVP.000.005 — Baseline Test (5-Minute Timer)
**Title:** New User Runs a 5-Minute Practice Session  
**Persona:** All  
**Why:** Introduces the timer experience; calculates initial 1RM.

**User Story:**
> As a new user, I want to complete a short 5-minute focus session during onboarding so I experience the timer, can test the "Distracted" button, and get my first 1RM measurement.

**Acceptance Criteria:**
- [ ] Timer is hardcoded to 5 minutes (not user-selectable).
- [ ] User can tap "Distracted" button (laps are recorded).
- [ ] Classification modal appears after each tap (standard 5-second auto-dismiss).
- [ ] Session auto-ends at 5:00 (or user can tap "Finish" earlier).
- [ ] Quality score is calculated and shown.
- [ ] First session is saved to local SQLite as a real data entry.

**Effort:** 🟡 Medium (6 days)  
**Dependencies:** Chronometer widget, Lap trigger, Quality Score formula

**Tasks:**
- [ ] Create simplified onboarding Timer screen (reuse main timer logic).
- [ ] Record laps into an in-memory session object.
- [ ] Calculate and display quality score (using standard formula).
- [ ] Save session to DB on completion.

---

### MVP.000.006 — The Founder's Oath (Privacy Overview)
**Title:** New User Acknowledges the Local-First Privacy Commitment  
**Persona:** All  
**Why:** Trust-building; explains the core value prop (your data stays local).

**User Story:**
> As a new user, I want a final privacy overview confirming that my focus data stays on my device (unless I opt-in to cloud sync) so I can trust NeuroLoad with my personal information.

**Acceptance Criteria:**
- [ ] Screen explains: "Local-First Encryption: Your data stays on your device."
- [ ] Bullet points cover: No telemetry, optional cloud sync, GDPR right to delete.
- [ ] User must tap "I Agree" to proceed.
- [ ] Tapping "I Agree" sets `SharedPreferences['onboarding_complete'] = true`.
- [ ] Next screen is the main Home screen (not onboarding anymore).

**Effort:** 🟢 Small (2 days)  
**Dependencies:** None

**Tasks:**
- [ ] Write privacy statement (200 words max).
- [ ] Build static screen with "I Agree" button.
- [ ] Update SharedPreferences flag.
- [ ] Route to Home screen on completion.

---

# EPIC 1: CORE TIMER & SESSION MANAGEMENT
## (The "Gym" — MVP Only)

### MVP.001.001 — Start a Session Manually
**Title:** User Taps "Start" Button to Begin a Focus Session  
**Persona:** All (especially Aisha, who may not trust face-down trigger)  
**Why:** Manual start is the accessibility fallback; critical for UX completeness.

**User Story:**
> As a user on the pre-session setup screen, I want to click a primary "Start Session" button so I can begin my focus timer without needing to flip my phone face-down.

**Acceptance Criteria:**
- [ ] "Start Session" button is disabled until user selects a Primary Category (Study, Work, Creative, Admin, Lifestyle).
- [ ] Clicking "Start" records `session.start_time = DateTime.now()`.
- [ ] App navigates to the Main Timer Screen.
- [ ] Session is created in local SQLite with `status = "active"`.

**Effort:** 🟢 Small (3 days)  
**Dependencies:** Category selection UI, Riverpod session provider

**Tasks:**
- [ ] Build 5-category radio/pill button selector.
- [ ] Implement conditional "Start" button enablement.
- [ ] Create `createSession()` function in Drift DAO.
- [ ] Wire button to navigation.

---

### MVP.001.002 — Start a Session via Face-Down Trigger
**Title:** User Flips Phone Face-Down to Auto-Start Timer  
**Persona:** Aisha, Marcus (convenience-focused)  
**Why:** Reduces friction; core "feel" differentiator.

**User Story:**
> As a user on the setup screen, I want to flip my phone face-down on my desk to automatically start the session so I can begin immediately without touching the screen.

**Acceptance Criteria:**
- [ ] Proximity sensor detects `proximity.isNear == true`.
- [ ] Gyroscope detects `gravity.z > threshold` (face-down orientation).
- [ ] Both conditions met for >500ms (debounce false triggers).
- [ ] Session starts immediately; haptic "Double-Success Tap" confirms.
- [ ] If any setup field is missing (category, intent), face-down trigger is ignored (shows inline prompt).

**Effort:** 🟡 Medium (6 days)  
**Dependencies:** `sensors_plus` package, sensor calibration baseline

**Tasks:**
- [ ] Set up sensor listeners on setup screen (StreamSubscription).
- [ ] Implement debounce logic (avoid 10x triggers).
- [ ] Test on 3 devices (iPhone + 2x Android) to validate reliability.
- [ ] Add fallback: "Oops, try again" toast if trigger fails.

---

### MVP.001.003 — The Breathing Ring (Chronometer Design)
**Title:** Timer Displays a Pulsing Ring (Visual Anchor)  
**Persona:** All  
**Why:** Reduces "time-anxiety"; elegant design differentiator.

**User Story:**
> As a user during a focus session, I want to see a continuously pulsing circle (breathing at 6 cycles/min) so I can anchor my attention without obsessively watching the clock.

**Acceptance Criteria:**
- [ ] Ring is 280dp diameter, 4dp stroke, Silver Age Gray color.
- [ ] Opacity animates: 100% → 85% → 100% over 10 seconds (exactly 6 cycles/minute).
- [ ] Ring continues pulsing even if the timer display is hidden (Ambient Mode).
- [ ] Ring is centered on screen; text timer (mm:ss) is overlaid.

**Effort:** 🟡 Medium (5 days)  
**Dependencies:** Custom Flutter widget, AnimationController

**Tasks:**
- [ ] Create custom `BreathingRing` widget using `CustomPaint` or `AnimatedBuilder`.
- [ ] Implement sine curve animation (smooth, not linear).
- [ ] Test animation performance (60fps target).
- [ ] Verify ring renders correctly on light + dark themes (if applicable).

---

### MVP.001.004 — Ambient Display (Hide Timer Text)
**Title:** User Double-Taps to Hide Clock and See Only Pulsing Ring  
**Persona:** Marcus (ADHD; time-anxiety reduction)  
**Why:** Reduces dopamine-chasing (clock-watching); psychological benefit.

**User Story:**
> As a user prone to time-anxiety, I want to double-tap the center of the screen to hide the digital clock (mm:ss) and see only the pulsing ring so I'm not tempted to stare at the timer.

**Acceptance Criteria:**
- [ ] Double-tap on the breathing ring toggles the timer text visibility.
- [ ] The ring continues pulsing regardless of text visibility.
- [ ] Double-tap again to show the text again (toggle, not one-way).
- [ ] Animation is smooth (200ms fade in/out).

**Effort:** 🟢 Small (2 days)  
**Dependencies:** GestureDetector, AnimatedOpacity

**Tasks:**
- [ ] Wrap timer text in `AnimatedOpacity` widget.
- [ ] Add `GestureDetector.onDoubleTap` listener to the ring.
- [ ] Toggle `textVisible` state boolean.

---

### MVP.001.005 — The "Distracted" Button (Large Touch Target)
**Title:** User Taps a Large Button to Log a Distraction  
**Persona:** All  
**Why:** Core interaction; must be intuitive, responsive, haptic-rich.

**User Story:**
> As a user distracted during a session, I want to tap a large, prominent button at the bottom of the screen so I can log the distraction without stopping the timer.

**Acceptance Criteria:**
- [ ] Button is 88dp height, screen width − 40dp (large, centered).
- [ ] Button text: "Distracted" (Crimson Noir color).
- [ ] Tapping triggers immediate haptic feedback: heavy "Thud" (iOS: `heavyImpact`, Android: `LONG_PRESS` pattern).
- [ ] Main timer does NOT pause; session continues counting.
- [ ] Lap object is created, timestamped, and added to session's lap list in-memory.
- [ ] Classification modal appears immediately after tap.

**Effort:** 🟢 Small (3 days)  
**Dependencies:** Haptics plugin, Lap model

**Tasks:**
- [ ] Build button widget with oversized dimensions.
- [ ] Implement haptic feedback call on tap.
- [ ] Create Lap object; append to session state (Riverpod).
- [ ] Trigger classification modal display.

---

### MVP.001.006 — Distraction Classification Modal
**Title:** Modal Appears with 6 Trigger Icons for User to Classify Distraction  
**Persona:** All  
**Why:** Provides data-driven insight ("What distracts me?"); essential for Coach logic.

**User Story:**
> As a user who just logged a distraction, I want a quick modal with 6 icons (Phone, Hunger, Noise, Internal, People, Bio) to classify what distracted me so the app can identify my personal "Danger Zones."

**Acceptance Criteria:**
- [ ] Modal appears as bottom sheet (non-dismissible by swipe initially).
- [ ] 2 columns × 3 rows of icons (6 total: Phone, Hunger, Noise, Internal, People, Bio).
- [ ] Each icon is 40dp with label below.
- [ ] Tapping an icon selects it (highlight, color change).
- [ ] A 5-second countdown progress bar shrinks from 100% → 0% at the bottom.

**Effort:** 🟡 Medium (5 days)  
**Dependencies:** Bottom sheet UI, progress animation

**Tasks:**
- [ ] Design 6 icons (Ligne Claire style; use flutter_svg or custom paint).
- [ ] Build bottom sheet layout (2-col grid).
- [ ] Implement 5-second timer with animated progress bar (using ClipPath or LinearProgressIndicator).
- [ ] Test layout on small phones (se iPhone + older Androids).

---

### MVP.001.007 — Lap Text Field (Optional Note)
**Title:** After Selecting a Trigger Icon, User Can Add a 4-Word Note  
**Persona:** Marcus (detail-oriented; self-tracking)  
**Why:** Adds context ("Why was I distracted?"); improves Coach insights.

**User Story:**
> As a user who selected a distraction trigger, I want to optionally type up to 4 words to add context (e.g., "Thought about groceries") so the app understands the specific distraction pattern.

**Acceptance Criteria:**
- [ ] Text field appears only if an icon is selected (hidden by default).
- [ ] Max 4 words enforced (validation on every keystroke).
- [ ] Character count displayed (e.g., "2/4 words").
- [ ] Pressing done / auto-dismissing saves the note to the Lap object.
- [ ] If modal auto-closes after 5 seconds, note text is ignored (no note saved).

**Effort:** 🟢 Small (3 days)  
**Dependencies:** Text validation logic

**Tasks:**
- [ ] Build conditional text input (visibility depends on selected trigger).
- [ ] Implement word-count validation (regex split by spaces).
- [ ] Save note string to Lap object.
- [ ] Test edge cases: empty string, single space, exactly 4 words.

---

### MVP.001.008 — 5-Second Auto-Dismiss Modal
**Title:** If User Doesn't Select a Trigger, Modal Auto-Closes After 5 Seconds  
**Persona:** All  
**Why:** Prevents modal from blocking flow; reduces friction.

**User Story:**
> As a user who gets distracted while classifying a distraction, I want the modal to automatically close after 5 seconds if I don't select anything so I'm back to focusing immediately.

**Acceptance Criteria:**
- [ ] After 5000ms, modal closes automatically.
- [ ] Lap is saved with `trigger = "Involuntary"` (no category selected).
- [ ] No notification; seamless return to timer.
- [ ] Selecting an icon before timeout cancels the countdown.

**Effort:** 🟢 Small (2 days)  
**Dependencies:** Timer widget, state management

**Tasks:**
- [ ] Implement Future.delayed(Duration(seconds: 5)) logic.
- [ ] Cancel timer if icon is tapped (via controller.cancel()).
- [ ] Set default trigger value on modal close.

---

### MVP.001.009 — End a Session (Manual)
**Title:** User Holds "Finish" Button for 2 Seconds to End Session  
**Persona:** All  
**Why:** Prevents accidental session termination; intentional UX.

**User Story:**
> As a user ready to end my focus session, I want to hold down a "Finish" button for 2 seconds so I don't accidentally stop the timer with an errant tap.

**Acceptance Criteria:**
- [ ] "Finish" button is at the bottom of the timer screen (opposite side from "Distracted").
- [ ] Pressing shows a visual progress ring filling over 2 seconds.
- [ ] If user releases before 2s, ring resets; nothing happens.
- [ ] If user holds for 2s, session ends; app navigates to Summary screen.
- [ ] Session `end_time = DateTime.now()` is recorded.

**Effort:** 🟡 Medium (5 days)  
**Dependencies:** LongPressGestureDetector, custom progress ring

**Tasks:**
- [ ] Build custom button with fill animation (ClipOval or AnimatedBuilder).
- [ ] Implement onLongPressStart / onLongPressEnd listeners.
- [ ] Calculate elapsed hold time; trigger finish at 2000ms.
- [ ] Test on different screen sizes + pointer speeds.

---

### MVP.001.010 — Quality Score Calculation
**Title:** After Session Ends, App Calculates Session Quality Score  
**Persona:** All  
**Why:** Gamification element; motivates improvement; core metric for Coach logic.

**User Story:**
> As a user who just finished a session, I want the app to calculate a Quality Score (0-100) based on my focus density and resilience so I can see a measurable metric of my training effort.

**Acceptance Criteria:**
- [ ] Quality Score formula:
  ```
  FD = (Session_Time - Recovery_Time) / Session_Time
  RS = Average_Resilience_Time (time from lap to modal-close)
  QS = (FD × 0.6) + (RS × 0.4) × 100
  ```
- [ ] Score is 0-100 (displayed as integer).
- [ ] FD is capped: if user had 0 laps, FD = 100% (perfect).
- [ ] Score displayed prominently on Summary screen (large font).

**Effort:** 🟡 Medium (4 days)  
**Dependencies:** Session data, lap data

**Tasks:**
- [ ] Write pure function `calculateQualityScore(session) → int`.
- [ ] Test with mock data (0 laps, 1 lap, 10 laps scenarios).
- [ ] Ensure formula is mathematically sound (no division by zero).

---

### MVP.001.011 — Post-Session Summary Screen
**Title:** User Sees a Summary Card with Quality Score, 1RM, and Top Distraction  
**Persona:** All  
**Why:** Reinforcement; motivates next session; clear feedback loop.

**User Story:**
> As a user who just finished a session, I want to see a beautiful summary card displaying my Quality Score, session 1RM, total laps, and top distraction so I understand my training performance.

**Acceptance Criteria:**
- [ ] Summary screen displays:
  - Quality Score (large, prominent, with "seal" graphic if new PB).
  - Session 1RM (longest continuous lap).
  - Total laps logged.
  - Top trigger category (e.g., "Phone: 4 laps").
- [ ] "Return to Home" button pops the screen.
- [ ] Session is persisted to local SQLite.

**Effort:** 🟡 Medium (5 days)  
**Dependencies:** Quality Score calculation, 1RM logic, UI design

**Tasks:**
- [ ] Design Summary card layout (Noir aesthetic, vintage seal graphic).
- [ ] Calculate session 1RM (max interval between laps or session boundaries).
- [ ] Count lap triggers; find most frequent.
- [ ] Render card dynamically based on calculated values.

---

### MVP.001.012 — The "Zombie Session" Guardrail
**Title:** If No Activity for 120 Minutes, Session is Auto-Capped  
**Persona:** All (especially busy professionals)  
**Why:** Prevents outlier data (phone left running all night) from skewing analytics.

**User Story:**
> As a user who accidentally left my app running for 2+ hours without interacting, I want the app to automatically cap the session so my 1RM and quality score aren't inflated by ghost time.

**Acceptance Criteria:**
- [ ] System tracks `last_interaction_time` (every tap, motion, or heartbeat).
- [ ] After 120 continuous minutes without interaction, session is marked `status = "parked"` (paused, not ended).
- [ ] Timer stops incrementing the focus density.
- [ ] Next app open: Recovery Modal appears asking "Was this really a deep focus session?"

**Effort:** 🟡 Medium (6 days)  
**Dependencies:** Background service or periodic check, shared prefs

**Tasks:**
- [ ] Implement `updateLastInteraction()` function (called on every tap/sensor event).
- [ ] Create periodic check (via Timer.periodic or background service) every 30 seconds.
- [ ] Logic: if `now - lastInteraction > 120min`, call `parkSession()`.
- [ ] Test by leaving app open for >2 hours locally (simulator).

---

### MVP.001.013 — Recovery Modal (After Zombie Session)
**Title:** User Confirms Actual Session End Time to Fix Zombie Session  
**Persona:** All  
**Why:** Data integrity; prevents artificial 1RM inflation.

**User Story:**
> As a user who opens the app after leaving it running, I want a modal asking "When did you actually stop focusing?" so the session time is accurate.

**Acceptance Criteria:**
- [ ] Modal appears on app launch if `status = "parked"` exists.
- [ ] Provides a time slider or text input to set the true `end_time`.
- [ ] User must confirm before continuing to home screen (blocking modal).
- [ ] Session is updated in DB with the corrected time.

**Effort:** 🟡 Medium (4 days)  
**Dependencies:** Modal UI, time picker

**Tasks:**
- [ ] Build time-input UI (slider or text field).
- [ ] Validate input (can't be after current time; can't be before start time).
- [ ] Update session record in DB.

---

# EPIC 2: LOCAL ANALYTICS & DASHBOARD
## (The "Dashboard" — MVP Only, Simplified)

### MVP.002.001 — Daily/Weekly Heatmap (24-Hour Circular)
**Title:** Dashboard Shows Circular Heatmap of Focus Time by Hour  
**Persona:** All (especially Marcus, who loves data)  
**Why:** Identifies "peak productivity hours"; core Coach input.

**User Story:**
> As a user viewing the Dashboard, I want a circular 24-hour heatmap where each hour block shows the intensity of my focus so I can identify when I'm most productive.

**Acceptance Criteria:**
- [ ] Heatmap is a circle (not a linear 24-hour bar).
- [ ] 24 segments (one per hour: 12am-11pm).
- [ ] Color intensity = focus minutes in that hour (0 = gray, max = intense Teal).
- [ ] Hover/tap a segment to see exact minute count.
- [ ] Toggle: Daily / Weekly / Monthly (tabs above heatmap).

**Effort:** 🔴 Large (8 days)  
**Dependencies:** `fl_chart` package or custom `CustomPainter`

**Tasks:**
- [ ] Design circular heatmap widget (CustomPainter route is better for Noir aesthetics).
- [ ] Aggregate session data by hour (SQLite query with time grouping).
- [ ] Map focus minutes to color intensity (linear gradient).
- [ ] Test with mock data (ensure colors scale correctly).
- [ ] Implement day/week/month toggle logic.

---

### MVP.002.002 — 1-Rep Max (1RM) Tracking
**Title:** Dashboard Displays User's All-Time and Weekly 1RM  
**Persona:** All  
**Why:** Gamification; core motivation (personal best tracking).

**User Story:**
> As a user on the Dashboard, I want to see my longest single focus session (1RM) and a weekly trend so I can track my improvement over time.

**Acceptance Criteria:**
- [ ] Displays:
  - All-time 1RM (max session duration).
  - Weekly 1RM (max in last 7 days).
  - Trend arrow (up/down/flat vs. previous week).
- [ ] Shows the date and category of the 1RM session.
- [ ] Tapping the 1RM card navigates to Trophy Room (future, Phase 2).

**Effort:** 🟡 Medium (4 days)  
**Dependencies:** 1RM calculation logic

**Tasks:**
- [ ] Write SQL query: `SELECT MAX(max_interval) FROM sessions WHERE created_at > NOW() - 7 days`.
- [ ] Compare to previous week; calculate trend.
- [ ] Build KPI card widget.

---

### MVP.002.003 — Distraction Trigger Breakdown (Pie Chart)
**Title:** Dashboard Shows Pie Chart of Distraction Categories  
**Persona:** Marcus (data-driven)  
**Why:** Identifies "focus killers"; informs Coach recommendations.

**User Story:**
> As a data-driven user, I want a pie chart showing the percentage of distractions caused by each trigger (Phone, Hunger, Noise, etc.) so I can identify my biggest focus killer.

**Acceptance Criteria:**
- [ ] Pie chart displays 6 trigger categories.
- [ ] Colors match the Ligne Claire icon palette (distinct per category).
- [ ] Tapping a slice highlights it; shows percentage and count.
- [ ] "No data yet" state if user has <3 laps.

**Effort:** 🟡 Medium (5 days)  
**Dependencies:** `fl_chart` package, Lap data aggregation

**Tasks:**
- [ ] Query: Count laps grouped by trigger category.
- [ ] Build pie chart using fl_chart.
- [ ] Handle no-data state gracefully.
- [ ] Test with 0, 5, 50 laps (edge cases).

---

### MVP.002.004 — Category-Specific Analytics Drill-Down
**Title:** User Can Filter All Dashboard Charts by Primary Category  
**Persona:** Elias (wants to understand "Study" focus vs. "Work")  
**Why:** Informs persona-specific strategies; enables targeted Coach logic.

**User Story:**
> As a student studying multiple subjects, I want to filter my dashboard analytics by category (Study, Work, Creative, etc.) so I can compare my focus performance across different types of work.

**Acceptance Criteria:**
- [ ] Dashboard has a dropdown or tab bar: "All Categories" + 5 primary categories.
- [ ] Selecting a category re-runs all queries (1RM, heatmap, pie chart) scoped to that category.
- [ ] Smooth transition animation when category changes.
- [ ] "No data" state if category has <2 sessions.

**Effort:** 🟡 Medium (4 days)  
**Dependencies:** State management (Riverpod), filtered queries

**Tasks:**
- [ ] Add category filter state (Riverpod StateNotifier).
- [ ] Refactor analytics queries to accept optional `category_id` parameter.
- [ ] Update heatmap, 1RM, pie chart to re-render on category change.

---

# EPIC 3: MONETIZATION & LICENSING
## (The "Paywall" — MVP Only)

### MVP.003.001 — Dynamic Pricing Display
**Title:** Landing Page / Paywall Shows Dynamic Pricing Tier  
**Persona:** Prospective users (all)  
**Why:** Creates scarcity urgency; drives conversions.

**User Story:**
> As a prospective buyer, I want to see the current pricing tier (Founder: €14.99) and how many spots are remaining so I feel urgency to purchase.

**Acceptance Criteria:**
- [ ] Paywall screen shows:
  - "Founder Batch: €14.99 (XXX spots remaining)"
  - Once 1,000 sold → "Early Adopter: €24.99 (XXX remaining)"
  - After 5,000 → "Standard: €49.99"
- [ ] Spot count decrements in real-time as users purchase (pulled from Stripe/backend).
- [ ] Clear explanation: "One-time payment. Own it forever. No subscriptions."

**Effort:** 🟡 Medium (5 days)  
**Dependencies:** Stripe API, backend pricing tier config

**Tasks:**
- [ ] Create `PricingService` class that fetches current tier from Supabase or Stripe.
- [ ] Calculate remaining spots (cap - current_user_count).
- [ ] Build paywall UI with dynamic pricing text.
- [ ] Test with mock pricing data.

---

### MVP.003.002 — Forced Paywall After One Session
**Title:** Free User Who Completed One Session Sees Blocking Paywall  
**Persona:** All (freemium funnel)  
**Why:** Monetization; captures users who've proved product-market fit.

**User Story:**
> As a free user who completed my first focus session, I want the app to show me a beautiful paywall the next time I open it so I understand the value before deciding to purchase.

**Acceptance Criteria:**
- [ ] On app launch, check: `session_count >= 1 AND license_status == "free"`.
- [ ] If true, push full-screen paywall modal (no "Back" button; blocks all navigation).
- [ ] Paywall shows:
  - Manifesto teaser ("Own your focus forever").
  - Current pricing tier + spots remaining.
  - "Buy Now" button (→ Stripe checkout).
  - "I Have a Code" button (voucher input, Phase 2).
- [ ] Paywall is dismissed only after successful payment or voucher entry.

**Effort:** 🟡 Medium (5 days)  
**Dependencies:** License status logic, Stripe integration

**Tasks:**
- [ ] Add `checkPaywallEligibility()` function (called on app startup).
- [ ] Build paywall UI.
- [ ] Store license status in SharedPreferences + Drift (local cache).
- [ ] Test: Start a session → close app → reopen → see paywall.

---

### MVP.003.003 — Stripe Checkout Integration
**Title:** User Clicks "Buy" and Completes Stripe Checkout  
**Persona:** All (buyers)  
**Why:** Core revenue funnel; must be frictionless.

**User Story:**
> As a buyer on the paywall, I want to click "Buy Now" and securely enter my payment info via Stripe so I can purchase a lifetime license.

**Acceptance Criteria:**
- [ ] "Buy Now" button opens Stripe-hosted checkout page (in-app browser or native Custom Tab).
- [ ] Stripe handles payment processing (PCI-compliant; never see credit card).
- [ ] On successful payment, Stripe webhook triggers backend to set `license_status = "paid"` in Supabase.
- [ ] App receives webhook confirmation; updates local license cache.
- [ ] User is returned to app; paywall dismisses; home screen shows.
- [ ] Payment failure shows error message; user can retry.

**Effort:** 🔴 Large (10 days)  
**Dependencies:** Supabase Edge Functions, Stripe API, url_launcher

**Tasks:**
- [ ] Create Supabase Edge Function: `create-checkout-session` (calls Stripe API).
- [ ] Return checkout URL to app.
- [ ] Implement `url_launcher` to open Stripe URL in Custom Tab (iOS) or WebView (Android).
- [ ] Create webhook handler in Supabase: `handle-stripe-webhook` (verify signature).
- [ ] On webhook success, update profiles.has_paid = true.
- [ ] Test end-to-end in Stripe sandbox environment.

---

### MVP.003.004 — License Status Verification
**Title:** App Checks If User Is Paid Before Allowing Full Access  
**Persona:** All  
**Why:** Prevents piracy; ensures revenue capture.

**User Story:**
> As the app, I want to verify the user's license status (paid vs. free) on app launch so unpaid users see the paywall and paid users access the full app.

**Acceptance Criteria:**
- [ ] On app startup, check `SharedPreferences['license_status']`.
- [ ] If "paid", skip paywall; show home screen.
- [ ] If "free" and session_count >= 1, show paywall.
- [ ] If "free" and session_count == 0, allow 1 session then show paywall.
- [ ] Background check (optional): periodically verify with Supabase that status is still valid.

**Effort:** 🟢 Small (3 days)  
**Dependencies:** SharedPreferences, Supabase client

**Tasks:**
- [ ] Add `isUserPaid()` function to AuthService.
- [ ] Call on app startup; store result in Riverpod provider.
- [ ] Wrap Home/Dashboard routes with license gate.
- [ ] Test with mock paid/free states.

---

### MVP.003.005 — GDPR Data Export (CSV)
**Title:** Paid User Can Download Their Focus Data as CSV  
**Persona:** All (especially Aisha, who values data ownership)  
**Why:** GDPR compliance (Article 20); trust-building; differentiator.

**User Story:**
> As a user who wants to own my data, I want to tap "Export Data" in Settings and download all my sessions and laps as a CSV file so I can analyze it or switch apps if needed.

**Acceptance Criteria:**
- [ ] Settings screen has "Export Data" button (red, danger zone).
- [ ] Tapping opens a confirmation dialog: "Export my focus data?"
- [ ] On confirm, app generates CSV(s):
  - `sessions.csv` (columns: date, duration, category, quality_score)
  - `laps.csv` (columns: session_id, trigger, note, time)
- [ ] App opens native Share sheet; user can email, save to Files, etc.
- [ ] Export is complete within 3 seconds (local operation; fast).

**Effort:** 🟡 Medium (5 days)  
**Dependencies:** CSV generation (dart:csv or manual string building), share_plus

**Tasks:**
- [ ] Write CSV generation functions (map session/lap objects → CSV strings).
- [ ] Test CSV parsing in Excel/Google Sheets (ensure no encoding issues).
- [ ] Implement share_plus integration.
- [ ] Test on iOS + Android.

---

### MVP.003.006 — GDPR Delete Account ("Wipe All Data")
**Title:** User Can Delete All Their Data with One Button (Right to Erasure)  
**Persona:** All (privacy-conscious)  
**Why:** GDPR Article 17 compliance; trust signal.

**User Story:**
> As a privacy-conscious user, I want a "Delete My Life" button in Settings that completely wipes my local app data and resets the app so I can remove all my focus history.

**Acceptance Criteria:**
- [ ] Settings screen has red "Delete All My Data" button (clearly in "Danger Zone").
- [ ] Tapping shows confirmation: "Type 'DELETE' to confirm".
- [ ] User must type "DELETE" in a text field; button is disabled until exact match.
- [ ] On confirm:
  - Delete all tables in local SQLite (Drift: `dao.deleteAll()` for each table).
  - Clear SharedPreferences (all cached settings).
  - Reset app to initial onboarding state.
  - Button disabled for 5 seconds post-deletion (prevent accidental double-click).
- [ ] No network request (purely local; instant).

**Effort:** 🟡 Medium (4 days)  
**Dependencies:** Drift DAO methods, SharedPreferences

**Tasks:**
- [ ] Add `deleteAllUserData()` function in AuthService.
- [ ] Implement confirmation text input.
- [ ] Test: Start 10 sessions → delete → verify DB is empty.

---

# EPIC 4: HARDWARE INTEGRATION & PLATFORM SPECIFICS
## (MVP Only, Simplified)

### MVP.004.001 — Haptic Feedback Library
**Title:** App Triggers Distinct Haptic Patterns for Different Events  
**Persona:** All (tactile feedback enhances UX)  
**Why:** Pavlovian conditioning (subconscious training); premium feel.

**User Story:**
> As a user, I want to feel distinct haptic vibrations for different session events (lap trigger, session finish, new PB) so my brain subconsciously learns the app's interaction pattern.

**Acceptance Criteria:**
- [ ] Session Start: Double-Success Tap (iOS: `successImpact`, Android: custom pattern).
- [ ] Lap Trigger: Heavy Thud (iOS: `heavyImpact`, Android: longer pulse).
- [ ] Session Finish: Ascending Pulse (iOS: custom, Android: vibrate 100-200-300ms).
- [ ] New 1RM PB: Fireworks Pulse (random intervals, celebratory).

**Effort:** 🟡 Medium (4 days)  
**Dependencies:** `flutter_haptic` package, platform channels

**Tasks:**
- [ ] Map haptic patterns to events.
- [ ] Test on iOS + Android devices.
- [ ] Ensure patterns don't feel jarring (users can disable in Settings, Phase 2).

---

### MVP.004.002 — Adaptive Sensor Polling (Battery Optimization)
**Title:** After 5 Minutes of Stability, Gyro Polling Reduces Frequency to Save Battery  
**Persona:** All (battery-conscious users)  
**Why:** Improves user experience; prevents 15%/hour battery drain.

**User Story:**
> As a user who runs long focus sessions (90+ minutes), I want the app to reduce sensor polling frequency after I'm stable (phone is reliably face-down) so my battery lasts longer.

**Acceptance Criteria:**
- [ ] Initial polling: 60hz (100ms updates).
- [ ] After 5 continuous minutes of stability (no motion > threshold), reduce to 5hz.
- [ ] Wake up to 60hz if significant motion detected (user moved phone).
- [ ] Battery impact: Estimated 5-10% reduction for 2-hour session.

**Effort:** 🟡 Medium (5 days)  
**Dependencies:** `sensors_plus` configuration

**Tasks:**
- [ ] Implement polling frequency state (initial vs. low-power).
- [ ] Add stability timer (5 min no-motion threshold).
- [ ] Test battery impact (measure with Apple Instruments + Android Battery Historian).

---

### MVP.004.003 — iOS Live Activities (Lock Screen Integration)
**Title:** iOS User Sees Timer on Lock Screen + Dynamic Island  
**Persona:** iOS users (Aisha, convenience)  
**Why:** Keeps app alive in background; prevents OS from killing session.

**User Story:**
> As an iOS user, I want to see my focus timer on my lock screen and dynamic island so the OS keeps my session alive in the background.

**Acceptance Criteria:**
- [ ] On session start, create iOS Live Activity.
- [ ] Activity shows: timer (mm:ss), laps count, current category.
- [ ] Updates every 1 minute (not every second; OS throttles frequent updates).
- [ ] On session end, dismiss Live Activity.
- [ ] Tapping activity returns to app (deep link).

**Effort:** 🟡 Medium (6 days)  
**Dependencies:** `live_activities` package, native Swift code

**Tasks:**
- [ ] Set up Live Activities entitlements in Xcode.
- [ ] Build Swift UI widget for lock screen.
- [ ] Implement timer updates via ActivityKit.
- [ ] Test on iOS 16+ device (requires physical device; simulator limited).

---

### MVP.004.004 — Android Foreground Service (Background Persistence)
**Title:** Android User Has Persistent Notification to Keep Session Alive  
**Persona:** Android users  
**Why:** Prevents OS from killing app during long sessions.

**User Story:**
> As an Android user, I want a persistent notification showing "Session Active" that keeps my app running in the background so a 2-hour session doesn't get killed.

**Acceptance Criteria:**
- [ ] On session start, launch Foreground Service.
- [ ] Notification shows: "NeuroLoad: Session Active" (non-dismissible).
- [ ] Tapping notification returns to app.
- [ ] On session end, dismiss Foreground Service + notification.

**Effort:** 🟡 Medium (5 days)  
**Dependencies:** `flutter_foreground_task` package, AndroidManifest config

**Tasks:**
- [ ] Add Foreground Service permission to AndroidManifest.
- [ ] Implement service lifecycle (onCreate, onStart, onDestroy).
- [ ] Test on Android 12+ (SCHEDULE_EXACT_ALARM permission).

---

# EPIC 5: SETTINGS & PRIVACY
## (MVP Minimum, Phase 2 Expansion)

### MVP.005.001 — Settings Screen (Scaffolding)
**Title:** User Can Access Settings (Delete Data, Export Data, Privacy Policy)  
**Persona:** All  
**Why:** Essential for GDPR compliance; trust-building.

**User Story:**
> As a user, I want a Settings screen accessible from the main navigation so I can delete my data, export it, and review privacy info.

**Acceptance Criteria:**
- [ ] Settings screen has sections:
  - **Privacy:** Delete Account, Export Data, View Privacy Policy.
  - **About:** Version, Copyright, Impressum link.
- [ ] All buttons functional (wired to their respective flows).

**Effort:** 🟢 Small (2 days)  
**Dependencies:** None (UI scaffold; functions implemented separately)

**Tasks:**
- [ ] Build settings list layout.
- [ ] Wire buttons to navigation routes.

---

### MVP.005.002 — Impressum Page (German Legal Compliance)
**Title:** User Can View Legally Required Business Information (Impressum)  
**Persona:** German users, compliance officers  
**Why:** Legally required for German telemedia (§5 TMG).

**User Story:**
> As a German user or regulator, I want to find the app's Impressum (company info, contact details) to verify the operator's identity and compliance.

**Acceptance Criteria:**
- [ ] Settings > About > "Impressum" → static page with:
  - Your full name.
  - Address (Cologne).
  - Contact email + phone.
  - VAT ID (if applicable).
  - EU ODR platform link (https://ec.europa.eu/consumers/odr/).
- [ ] Page is in English + German (Phase 2 localization; MVP can be English-only with "German coming soon").

**Effort:** 🟢 Small (1 day)  
**Dependencies:** Legal text (prepare in advance)

**Tasks:**
- [ ] Write Impressum text (copy-paste from PRD Section 8.3).
- [ ] Build static screen.

---

### MVP.005.003 — Privacy Policy & Terms Link
**Title:** User Can Access Full Privacy Policy and Terms of Service  
**Persona:** All (especially careful buyers)  
**Why:** Legal requirement; transparency.

**User Story:**
> As a user, I want to access the full Privacy Policy and Terms of Service within the app so I understand what data is collected and how it's used.

**Acceptance Criteria:**
- [ ] Settings > Links: "Privacy Policy" + "Terms of Service".
- [ ] Both open in-app (as static screens or webview pointing to your website).
- [ ] Text covers:
  - Local-first encryption.
  - Data processors (Supabase, Stripe).
  - GDPR rights (Article 17, 20).
  - Medical disclaimers (not a substitute for professional advice).

**Effort:** 🟢 Small (2 days)  
**Dependencies:** Legal text (pre-written in PRD)

**Tasks:**
- [ ] Convert legal markdown to Flutter UI screens.
- [ ] Test readability on small phones.

---

# EPIC 6: PHASE 2+ FEATURES (DEFERRED)
## (Do NOT build in MVP; reference for prioritization in Phase 2)

### Phase2.001.001 — Cloud Sync (Supabase Integration)
**Status:** DEFERRED TO PHASE 2  
**Why Deferred:** Requires complex conflict resolution; low priority for single-device users.  
**Effort:** 🔴 Large (12-15 days)  

**Story Summary:**
> As a multi-device user (phone + iPad + laptop), I want my focus sessions to sync across devices so I can view analytics on any device.

---

### Phase2.002.001 — Break Management (The 20% Rule)
**Status:** DEFERRED TO PHASE 2  
**Why Deferred:** Non-core for MVP; can iterate locally first.  
**Effort:** 🟡 Medium (6-8 days)

**Story Summary:**
> As a user after a 50-minute focus session, I want to earn a 10-minute break so I rest proportionally to my effort.

---

### Phase2.003.001 — Coach Logic: De-load Week Detection
**Status:** DEFERRED TO PHASE 2  
**Why Deferred:** Requires 2-3 weeks of data; not applicable in MVP.  
**Effort:** 🟡 Medium (4-5 days)

**Story Summary:**
> As a user whose focus density drops below 60% for 3 sessions, I want the Coach to suggest a "de-load week" (shorter targets) to rebuild confidence.

---

### Phase2.004.001 — Circadian Rhythm Mapping
**Status:** DEFERRED TO PHASE 2  
**Why Deferred:** Requires historical data aggregation; power-user feature (Marcus persona).  
**Effort:** 🟡 Medium (5-6 days)

**Story Summary:**
> As a self-tracking user, I want the Coach to identify my "Biological Prime Time" (peak focus hours) so I schedule hard work accordingly.

---

### Phase2.005.001 — Invoice Generation (Tax Deductibility)
**Status:** DEFERRED TO PHASE 2  
**Why Deferred:** Nice-to-have for Elias persona; Stripe auto-invoices suffice for MVP.  
**Effort:** 🟡 Medium (4 days)

**Story Summary:**
> As a student/professional, I want an automatically generated invoice so I can claim a tax deduction.

---

### Phase3.001.001 — B2B Coach Dashboard (Next.js)
**Status:** DEFERRED TO PHASE 3  
**Why Deferred:** Requires Next.js web portal; not MVP-critical.  
**Effort:** 🔴 Large (10-15 days)

**Story Summary:**
> As a university manager, I want a web dashboard to distribute seat codes to 50 students and view aggregate focus metrics.

---

### Phase3.002.001 — Study Lounges (Co-Working Rooms)
**Status:** DEFERRED TO PHASE 4  
**Why Deferred:** Requires Supabase Realtime; complex feature; low retention impact vs. effort.  
**Effort:** 🔴 Large (15-20 days)

**Story Summary:**
> As a remote student, I want to join a virtual focus room with others so I feel accountability and community.

---

# APPENDIX: USER STORY PRIORITIZATION MATRIX

### MVP Scope by Estimated Effort

```
EPIC | Total Stories | Total Effort | Must-Ship
-----|---|---|---
Epic 0 (Onboarding) | 6 | ~20 days | ✅ YES
Epic 1 (Timer/Session) | 13 | ~60 days | ✅ YES
Epic 2 (Dashboard) | 4 | ~22 days | ✅ YES
Epic 3 (Monetization) | 6 | ~27 days | ✅ YES
Epic 4 (Hardware) | 4 | ~20 days | ✅ YES
Epic 5 (Settings) | 3 | ~5 days | ✅ YES

TOTAL MVP EFFORT: ~154 story points / ~6 months (40h/week)
```

### Phase 2 Backlog (Estimated)

```
Feature | Effort | Impact on Retention
---|---|---
Cloud Sync | 🔴 12 days | +15% (multi-device)
Break Management | 🟡 6 days | +3%
Coach De-load Logic | 🟡 4 days | +2%
Circadian Mapping | 🟡 5 days | +8% (Marcus persona)
Invoice Generation | 🟡 4 days | +5% (B2B acquisition)

Phase 2 Total: ~31 days (4-5 weeks for 1 dev + VA support)
```

---

# SUCCESS CRITERIA FOR MVP LAUNCH

You are **ready to launch** when:

- [ ] **All 32 MVP user stories** are implemented and tested.
- [ ] **Beta testing** with 50 users shows NPS > 35.
- [ ] **Crash rate** < 2% (tested for 100+ hours).
- [ ] **Payment flow** works end-to-end in Stripe sandbox.
- [ ] **App Store submission** passes Apple/Google review (no rejection on "app blocker" policy).
- [ ] **Legal documents** (ToS, Privacy, Impressum) reviewed by lawyer.
- [ ] **GDPR compliance** (delete/export functionality) verified.
- [ ] **First 5 "love letters"** (testimonials) collected from beta users.

---

**Document Prepared By:** Senior Business Analyst & Strategist  
**For:** NeuroLoad Founder  
**Version:** 2.0 Persona-Driven, MVP-Focused  
**Last Updated:** March 2026


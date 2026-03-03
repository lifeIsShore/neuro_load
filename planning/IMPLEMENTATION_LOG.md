# NeuroLoad — Implementation Log
**Last Updated:** 2026-03-03  
**Author:** AI Engineering Assistant  
**Purpose:** Track which user stories are done, in-progress, or pending, with prerequisites noted for the dev team.

---

## Legend
- ✅ **DONE** — Fully implemented and wired up
- 🔨 **PARTIAL** — UI/shell exists, but backend logic is a stub or TODO
- ❌ **NOT STARTED** — No code exists for this story
- 🔒 **BLOCKED** — Cannot start until a prerequisite is done

---

## EPIC 0 — Onboarding (The 4-Step Indoctrination)

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| MVP.000.001 | The Manifesto Screen | ✅ DONE | Typewriter animation, scroll-to-unlock, `has_completed_onboarding` SharedPrefs flag — all implemented in `onboarding_screen.dart` |
| MVP.000.002 | Lap Mechanic Tutorial | ✅ DONE | Interactive mock DISTRACTED button with haptic, tap-to-proceed logic in `_LapTutorialPage` |
| MVP.000.003 | Sensor Calibration | 🔨 PARTIAL | UI page exists (`_SensorCalibrationPage`), but **no actual sensor sampling or SharedPrefs baseline storage** — the page is currently descriptive text only |
| MVP.000.004 | Intent Statement Practice | ✅ DONE | Text input with 10-char minimum validation, in `_IntentPracticePage` |
| MVP.000.005 | Baseline Test (5-min timer) | 🔨 PARTIAL | Page UI exists (`_BaselineTestPage`) but it is **informational only** — no embedded live timer, no session saved from onboarding |
| MVP.000.006 | Founder's Oath / Privacy Overview | ✅ DONE | Three privacy bullet points, "I Agree" button sets the onboarding flag and navigates to `/setup` |

---

## EPIC 1 — Core Timer & Session Management

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| MVP.001.001 | Start Session Manually | ✅ DONE | Category selector enables Start button; `startSession()` writes to Drift DB and navigates to `/timer` |
| MVP.001.002 | Start via Face-Down Trigger | ✅ DONE | `sensor_provider.dart` + `faceDownStartProvider` drives automatic session start from setup screen with haptic confirm |
| MVP.001.003 | Breathing Ring (Chronometer Design) | ✅ DONE | `BreathingRing` widget — custom painter, 10-second sine pulse animation, continuous regardless of clock visibility |
| MVP.001.004 | Ambient Display / Hide Timer Text | ✅ DONE | Double-tap `GestureDetector` toggles `_showClock` with `AnimatedOpacity` (400ms) |
| MVP.001.005 | Distracted Button | ✅ DONE | 88dp height, heavy haptic on tap, session continues, lap appended to Riverpod state |
| MVP.001.006 | Distraction Classification Modal | ✅ DONE | `DistractionModal` bottom sheet with 6 trigger icons (Phone, Noise, Need, Thought, Fatigue, Involuntary), 5-second progress bar |
| MVP.001.007 | Lap Text Field (4-word note) | ✅ DONE | Optional text input shown after icon selected, word-count validation in `distraction_modal.dart` |
| MVP.001.008 | 5-Second Auto-Dismiss | ✅ DONE | `Future.delayed(5s)` auto-closes modal and defaults to `DistractionTrigger.involuntary` |
| MVP.001.009 | End Session (Long-Press Finish) | ✅ DONE | `LongPressFinishButton` widget with circular fill animation over 2 seconds; cancels if released early |
| MVP.001.010 | Quality Score Calculation | ✅ DONE | `SessionState.qualityScore` computed from focus density minus lap penalty; persisted via `finishSession()` |
| MVP.001.011 | Post-Session Summary Screen | ✅ DONE | `SummaryScreen` shows Quality Score card, Session 1RM, Focus Density, Lap count, Top Distraction trigger |
| MVP.001.012 | Zombie Session Guardrail | 🔨 PARTIAL | `resumeZombieSession()` method exists in `SessionNotifier`, but **no background Timer.periodic or periodic check logic is wired yet** |
| MVP.001.013 | Recovery Modal (After Zombie) | ❌ NOT STARTED | No launch-check for parked sessions and no recovery UI/modal built |
| US 1.9 | Haptic Milestones (10-min ticks) | ✅ DONE | `_checkHapticMilestone()` in timer triggers `HapticFeedback.lightImpact()` at every 600 seconds |

---

## EPIC 2 — Local Analytics & Dashboard

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| MVP.002.001 | Focus Heatmap (daily grid) | 🔨 PARTIAL | 90-day GitHub-style grid heatmap implemented (`_FocusHeatmap`); **not the spec's 24-hour circular heatmap** — uses day count, no daily/weekly/monthly toggle |
| MVP.002.002 | 1RM Tracking | ✅ DONE | `allTimeOneRmProvider` queries DB; KPI card shows all-time 1RM; line chart `_OneRMLineChart` shows 1RM progression over sessions |
| MVP.002.003 | Distraction Trigger Breakdown | ✅ DONE | `_DistractionDoughnut` pie/donut chart via `fl_chart`; uses `triggerCountMapProvider`; handles empty state |
| MVP.002.004 | Category-Specific Analytics Filter | ❌ NOT STARTED | No category dropdown/tab in Dashboard; all queries are unfiltered |
| US 3.3 | Focus Density KPI | ✅ DONE | `avgFocusDensityProvider` shown as a KPI card |
| US 3.8 | Trophy Room | 🔨 PARTIAL | Trophy Room KPI card tappable in dashboard but `onTap: () {}` is a stub — **no `/trophies` route, no screen built** |
| US 4.1 | Coach — Silent Week / Baseline Gate | ✅ DONE | `CoachEngine._baselineThreshold = 10`; shows "X sessions until Coach Intelligence unlocks" until threshold |
| US 4.2 | Coach — +5% Next Aim Suggestion | ✅ DONE | `CoachEngine` generates `nextAimSuggestion` after baseline; `nextAimProvider` available |
| US 4.3 | Coach — De-load Warning | ✅ DONE | Detects >15pt quality drop over last 3 sessions and surfaces `deloadWarning` insight |
| US 4.x | Coach — PB Detection | ✅ DONE | Detects if latest session 1RM equals all-time 1RM and flashes "New All-Time 1RM!" insight |
| US 4.x | Coach — Distraction Pattern | ✅ DONE | Identifies top trigger category and shows percentage insight |

---

## EPIC 3 — Monetization & Licensing

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| MVP.003.001 | Dynamic Pricing Display | 🔨 PARTIAL | `PaywallScreen` exists; pricing copy is **hardcoded**, not fetched from Stripe/Supabase |
| MVP.003.002 | Forced Paywall After One Session | 🔨 PARTIAL | `/paywall` route exists; **no launch-check logic wired** — the session count gate (`checkPaywallEligibility()`) is not implemented; users are never redirected automatically |
| MVP.003.003 | Stripe Checkout Integration | ❌ NOT STARTED | "Buy Now" button is a stub (`onTap: () {}`); no Supabase Edge Function created |
| MVP.003.004 | License Status Verification | ❌ NOT STARTED | Settings shows hardcoded "FREE" status; no `isUserPaid()` function |
| MVP.003.005 | GDPR Data Export (CSV) | 🔨 PARTIAL | Settings has "Export Data" tile wired to `onTap: () {}`; **no CSV generation or `share_plus` integration** |
| MVP.003.006 | GDPR Delete Account (Wipe Data) | 🔨 PARTIAL | Confirmation dialog exists; **`// TODO: implement full DB teardown`** comment present; no actual DB wipe implemented |

---

## EPIC 5 — Security & Privacy (local)

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| US 5.1 | Local-First Data Storage (Drift) | ✅ DONE | All data stored in Drift SQLite (`app_database.dart`); sessions and laps persisted on finish |
| US 5.3 | Data Export | 🔨 PARTIAL | See MVP.003.005 above |
| US 5.4 | Cloud Sync (Opt-In, Paid) | ❌ NOT STARTED | Toggle exists in Settings UI but has no backend integration |
| US 5.5 | Strict Privacy Toggle (Local Notes) | 🔨 PARTIAL | `localOnlyNotes` toggle exists in Settings and AppSettings state; **no sync payload logic to respect it** |

---

## EPIC 7 — Hardware & System Polish

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| US 7.1 | Lap Feed UI | ✅ DONE | `LapFeed` widget with `ListView.builder` shows a chronological list of laps with trigger emoji and note |
| US 7.3 | Adaptive Sensor Polling | ❌ NOT STARTED | `sensors_plus` stream active but no throttle/polling frequency logic |
| US 7.4 | Live Activities (iOS) | ❌ NOT STARTED | Not implemented |
| US 7.5 | Foreground Service (Android) | 🔨 PARTIAL | `NotificationService.showSessionActive()` sends a persistent notification every 60 ticks; **no true Foreground Service / `flutter_foreground_task`** |
| US 2.1 | Dynamic Break Earning | 🔨 PARTIAL | `break_timer_screen.dart` in `/summary` with teal color-shift UI; **break duration formula not implemented** — hardcoded duration |
| US 2.2 | Break UI Color Shift | ✅ DONE | `BreakTimerScreen` uses teal/sage palette distinct from session mode |

---

## EPIC 8 — Onboarding Full Spec Gaps
*(See Epic 0 table above for current status. Additional story-level gaps:)*

- **MVP.000.003 Sensor Calibration** — Missing actual sensor reads and baseline storage. Needs `sensors_plus` stream listener, 3-sample averaging, and `SharedPreferences.setDouble()` writes.
- **MVP.000.005 Baseline Test** — Should launch an embedded timer (reusing `TimerScreen` logic), record laps, and save session to DB before proceeding to oath screen.

---

## Key Technical Gaps Summary

| Priority | Gap | Affected Stories |
|----------|-----|-----------------|
| 🔴 HIGH | Paywall gate not wired to app startup | MVP.003.002, MVP.003.004 |
| 🔴 HIGH | Stripe Checkout not integrated | MVP.003.003 |
| 🔴 HIGH | Zombie session periodic check not running | MVP.001.012/013 |
| 🟡 MED | CSV Export not implemented | MVP.003.005 |
| 🟡 MED | DB Wipe logic stub only | MVP.003.006 |
| 🟡 MED | Trophy Room screen missing | US 3.8 |
| 🟡 MED | Category filter for Dashboard missing | MVP.002.004 |
| 🟡 MED | Sensor calibration in onboarding is UI-only | MVP.000.003 |
| 🟡 MED | Heatmap is daily grid, not 24-hour circular | MVP.002.001 |
| 🟢 LOW | Baseline Test in onboarding is static | MVP.000.005 |
| 🟢 LOW | Adaptive sensor polling not throttled | US 7.3 |
| 🟢 LOW | iOS Live Activities not started | US 7.4 |

---

## What's in Excellent Shape ✅

The **core training loop** is production-quality:
- Full 6-page onboarding flow with real interactions (typewriter, scroll gate, haptics)
- Setup screen: category, sub-category, baseline aim, intent, face-down sensor trigger
- Timer: breathing ring, ambient mode, haptic milestones, distraction modal with 6 icons + 5s auto-dismiss + 4-word notes, lap feed timeline, long-press finish
- Summary: quality score card with animated counter, 1RM display, focus density, top trigger
- Dashboard: 1RM KPI, avg density KPI, session count, 90-day heatmap, distraction doughnut, 1RM line chart, coach insights
- Coach engine: baseline gate, +5% aim, de-load warning, PB detection, distraction pattern
- Settings: cloud sync toggle, local-only notes toggle, high contrast toggle, danger zone (wipe) dialog stub
- Database: Drift schema (Sessions, Laps, AppSettings), DAOs, all KPIs computed and persisted

---

## Recommended Next Implementation Brick

### 🎯 NEXT: Trophy Room Screen

**Why first?** It's a self-contained screen with no external dependencies (only reads existing DB data). It closes a visible gap in the Dashboard (the tappable card goes nowhere), provides immediate user value, and is a fast win (~1–2 days).

**Prerequisites:**
- Sessions table already stores `sessionOneRmSeconds`, `category`, `startedAt` ✅
- Dashboard already has a tappable Trophy Room KPI card ✅

**What to build:**
1. Add `/trophies` route in `router.dart`
2. Create `lib/screens/trophy_room/trophy_room_screen.dart`
3. Add DAO query: `SELECT * FROM sessions WHERE isCompleted = 1 ORDER BY sessionOneRmSeconds DESC LIMIT 5`
4. Build a styled list with vintage-plaque card design (date, duration, category, session 1RM)
5. Wire the Dashboard "TROPHY ROOM" card `onTap` to `context.go('/trophies')`

**After Trophy Room, the recommended sequence is:**
1. **Paywall gate** (MVP.003.002+004) — revenue protection
2. **CSV Export** (MVP.003.005) — GDPR compliance
3. **DB Wipe** (MVP.003.006) — complete the danger zone
4. **Zombie Session periodic check** (MVP.001.012+013) — data integrity
5. **Stripe Checkout** (MVP.003.003) — full monetization

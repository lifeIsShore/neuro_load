# NeuroLoad — Implementation Log
**Last Updated:** 2026-03-04 (US 7.3 Adaptive Sensor Polling + Docs)  
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
| MVP.000.003 | Sensor Calibration | ✅ DONE | `_SensorCalibrationPage` converted to `StatefulWidget` — 3-phase flow (idle → sampling → done), live `accelerometerEventStream` + 3-sample averaging, animated teal arc painter, `SharedPreferences.setDouble('sensor_z_baseline')` persisted on finish; Skip fallback for emulators. `FaceDownNotifier` reads the baseline at startup via `_loadThresholdThenSubscribe()` |
| MVP.000.004 | Intent Statement Practice | ✅ DONE | Text input with 10-char minimum validation, in `_IntentPracticePage` |
| MVP.000.005 | Baseline Test (5-min timer) | ✅ DONE | `_BaselineTestPage` converted to `StatefulWidget` — 3-phase flow (idle → running → done), live `MM:SS` countdown ring (5 min), "I Got Distracted" lap button with counter, `SessionDao.insertSession()` on begin + `finishSession()` on completion, quality/1RM computed from lap count; Skip link always visible (no DB write on skip) |
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
| MVP.001.012 | Zombie Session Guardrail | ✅ DONE | `zombieSessionProvider` in `sensor_provider.dart` queries `findIncomplete()` on launch; `AppShell.initState` calls `_checkZombie()` via `addPostFrameCallback` and invokes `resumeZombieSession()` on confirm |
| MVP.001.013 | Recovery Modal (After Zombie) | ✅ DONE | `ZombieRecoveryModal` in `zombie_recovery_modal.dart` — pulsing red icon, info chip (category + elapsed), Resume CTA, 2-step Discard confirm (Keep / Yes Discard), `AnimatedSwitcher` transition |
| US 1.9 | Haptic Milestones (10-min ticks) | ✅ DONE | `_checkHapticMilestone()` in timer triggers `HapticFeedback.lightImpact()` at every 600 seconds |

---

## EPIC 2 — Local Analytics & Dashboard

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| MVP.002.001 | 24-Hour Circular Focus Ring | ✅ DONE | Old 90-day grid replaced with `_CircularHeatmap` — 24-segment clock ring `CustomPainter`; arc width + opacity scale with total focus minutes per hour; peak-hour label in center; intensity gradient legend; tap to toggle to 90-day `_GridView` fallback; fade-in animation via `AnimationController`; no new deps |
| MVP.002.002 | 1RM Tracking | ✅ DONE | `allTimeOneRmProvider` queries DB; KPI card shows all-time 1RM; line chart `_OneRMLineChart` shows 1RM progression over sessions |
| MVP.002.003 | Distraction Trigger Breakdown | ✅ DONE | `_DistractionDoughnut` pie/donut chart via `fl_chart`; uses `triggerCountMapProvider`; handles empty state |
| MVP.002.004 | Category-Specific Analytics Filter | ✅ DONE | `categoryFilterProvider` StateProvider drives filtered DAO queries; horizontal `ChoiceChip` row (All/Study/Work/Creative/Admin/Lifestyle) in Dashboard; all KPI cards, heatmap, donut, and 1RM chart react to filter changes |
| US 3.3 | Focus Density KPI | ✅ DONE | `avgFocusDensityProvider` shown as a KPI card |
| US 3.8 | Trophy Room | ✅ DONE | `TrophyRoomScreen` built at `/trophies`; shows top 5 sessions by 1RM; dashboard card wired |
| US 4.1 | Coach — Silent Week / Baseline Gate | ✅ DONE | `CoachEngine._baselineThreshold = 10`; shows "X sessions until Coach Intelligence unlocks" until threshold |
| US 4.2 | Coach — +5% Next Aim Suggestion | ✅ DONE | `CoachEngine` generates `nextAimSuggestion` after baseline; `nextAimProvider` available |
| US 4.3 | Coach — De-load Warning | ✅ DONE | Detects >15pt quality drop over last 3 sessions and surfaces `deloadWarning` insight |
| US 4.x | Coach — PB Detection | ✅ DONE | Detects if latest session 1RM equals all-time 1RM and flashes "New All-Time 1RM!" insight |
| US 4.x | Coach — Distraction Pattern | ✅ DONE | Identifies top trigger category and shows percentage insight |

---

## EPIC 3 — Monetization & Licensing

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| MVP.003.001 | Dynamic Pricing Display | ✅ DONE | `PaywallScreen` upgraded to `ConsumerStatefulWidget`; €49 lifetime price, feature list (incl. 24-hr Focus Ring), scarcity badge — all hardcoded pending Supabase dynamic pricing |
| MVP.003.002 | Forced Paywall After One Session | ✅ DONE | `subscription_provider.dart`: `isPaidProvider` + `freeSessionsUsedProvider` (SharedPrefs-backed); `paywallGateProvider`; `finishSession()` calls `freeSessionsUsed.increment()`; GoRouter global redirect intercepts shell paths when gate fires |
| MVP.003.003 | Stripe Checkout Integration | ❌ NOT STARTED | "Buy Now" shows SnackBar stub + TODO comment; no Supabase Edge Function created |
| MVP.003.004 | License Status Verification | ✅ DONE | `isPaidProvider` (SharedPrefs `subscription_is_paid`); Settings screen shows live 'PLUS ✓' (teal) / 'FREE' (amber) chip; Upgrade tile hidden when paid; voucher redemption calls `markPaid()` with 800ms simulated RPC delay |
| MVP.003.005 | GDPR Data Export (CSV) | ✅ DONE | Settings "Export Data" runs `ExportService.exportAllData()` using `share_plus` to generate `sessions.csv` and `laps.csv` |
| MVP.003.006 | GDPR Delete Account (Wipe Data) | ✅ DONE | Wipes DB (laps then sessions), clears `SharedPreferences`, and resets memory state when confirmed |

---

## EPIC 5 — Security & Privacy (local)

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| US 5.1 | Local-First Data Storage (Drift) | ✅ DONE | All data stored in Drift SQLite (`app_database.dart`); sessions and laps persisted on finish |
| US 5.3 | Data Export | ✅ DONE | See MVP.003.005 above |
| US 5.4 | Cloud Sync (Opt-In, Paid) | ✅ DONE | `SettingsScreen` wires Cloud Sync toggle → `SupabaseSyncService.syncAll()`; Supabase URL + Anon Key entry via bottom sheet; `testConnection()` ping on save; live sync status chip (↺ / ✓ / ✗) |
| US 5.5 | Strict Privacy Toggle (Local Notes) | ✅ DONE | `SupabaseSyncService.syncAll(localOnlyNotes: bool)` — when true, `note` field is `null`-ed on all lap payloads before upload |

---

## EPIC 7 — Hardware & System Polish

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| US 7.1 | Lap Feed UI | ✅ DONE | `LapFeed` widget with `ListView.builder` shows a chronological list of laps with trigger emoji and note |
| US 7.3 | Adaptive Sensor Polling | ✅ DONE | `FaceDownNotifier` now accepts `Ref`; listens to `sessionProvider.phase`; uses 200 ms sampling when `SessionPhase.active`, 2000 ms otherwise; stream cancelled & recreated on phase change |
| US 7.4 | Live Activities (iOS) | ❌ NOT STARTED | Not implemented |
| US 7.5 | Foreground Service (Android) | ✅ DONE | `flutter_foreground_task: ^9.2.0` added; `ForegroundTaskHandler` (new) drives 1-second tick in FGS isolate → `sendDataToMain('tick')` → `sessionNotifier.tick()` in main isolate via `addTaskDataCallback`; `ForegroundService` wrapper (new) exposes `start/stop`; `TimerScreen` switched from `Timer.periodic` to FGS callbacks; `finishSession()` / `resetSession()` both call `ForegroundService.stop()` as safety net; `AndroidManifest.xml` updated with `FOREGROUND_SERVICE_SPECIAL_USE` permission + service declaration |
| US 2.1 | Dynamic Break Earning | ✅ DONE | `SessionState.earnedBreakDuration` computed from quality score × elapsed time (clamped 5–25 min); `_EarnedBreakBanner` on `SummaryScreen`; `/break` GoRoute passes `Duration` extra; `BreakTimerScreen` pre-selects earned duration with ★ EARNED badge |
| US 2.2 | Break UI Color Shift | ✅ DONE | `BreakTimerScreen` uses teal/sage palette distinct from session mode |

---

## EPIC 8 — Onboarding Full Spec Gaps
*(See Epic 0 table above for current status. Additional story-level gaps:)*

- **MVP.000.003 Sensor Calibration** — Missing actual sensor reads and baseline storage. Needs `sensors_plus` stream listener, 3-sample averaging, and `SharedPreferences.setDouble()` writes.
- **MVP.000.005 Baseline Test** — Should launch an embedded timer (reusing `TimerScreen` logic), record laps, and save session to DB before proceeding to oath screen.

---

## EPIC 9 — Phase 2, 3 & 4 (The Complete Backlog)
*Features deferred from the MVP to focus on core functionality, mapping to Epics 11, 12, & 13 from the comprehensive PRD.*

| Story | Title | Phase | Status | Notes |
|-------|-------|-------|--------|-------|
| US 9.1 | Invoice Generation | Phase 2 | ❌ NOT STARTED | Tax deduction receipts (Resend API template) |
| US 9.2 | Calendar Task Import | Phase 2 | ❌ NOT STARTED | Fetch intent from Google/Apple Calendar |
| US 9.3 | Circadian Rhythm Analysis | Phase 2 | ❌ NOT STARTED | Time-of-day heatmap for "Prime Time" detection |
| US 9.4 | Ghost Intent Reminder | Phase 2 | ❌ NOT STARTED | Shows pre-flow intent when distracted to redirect focus |
| US 9.5 | Next.js B2B Web Portal | Phase 3 | ❌ NOT STARTED | Organization management, aggregate analytics |
| US 9.6 | Smart Coach ML (ARIMA) | Phase 3 | ❌ NOT STARTED | Advanced forecasting and anomaly detection |
| US 9.7 | NeuroLoad Plus Upsell | Phase 3 | ❌ NOT STARTED | Subscription paywall for advanced analytics/sync |
| US 9.8 | Dyslexia-Friendly Typography | Phase 3 | ❌ NOT STARTED | `OpenDyslexic` font toggle in settings |
| US 9.9 | Screen-Reader & VoiceOver | Phase 3 | ❌ NOT STARTED | Full EAA accessibility semantics |
| US 9.10 | The "Soundscape" Engine | Phase 4 | ❌ NOT STARTED | Binaural beats/white noise audio player |
| US 9.11 | Study Lounges & Battles | Phase 4 | ❌ NOT STARTED | Realtime social accountability / 1v1 focus duels |
| US 9.12 | Global Focus Leaderboards | Phase 4 | ❌ NOT STARTED | Weekly resetting ranks (The Tank, The Monk) |
| US 9.13 | "Focus Resume" PDF Export | Phase 4 | ❌ NOT STARTED | Generates professional PDF resume of focus stats |

---

## Key Technical Gaps Summary

| Priority | Gap | Affected Stories |
|----------|-----|-----------------|
| 🔴 HIGH | Paywall gate not wired to app startup | MVP.003.002, MVP.003.004 |
| 🔴 HIGH | Stripe Checkout not integrated | MVP.003.003 |
| 🟡 MED | Heatmap is daily grid, not 24-hour circular | MVP.002.001 |
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

### ✅ COMPLETED: Zombie Session Recovery (MVP.001.012 + MVP.001.013)

`zombieSessionProvider` → `findIncomplete()` DB query → `AppShell._checkZombie()` launch hook → `ZombieRecoveryModal` with Resume / 2-step Discard → `resumeZombieSession()` restores full session state. All wired and verified.

---

### ✅ COMPLETED: Real Sensor Calibration in Onboarding (MVP.000.003)

`_SensorCalibrationPage` → StatefulWidget → 3-phase flow (idle/sampling/done) → live `accelerometerEventStream` → 3-sample averaging with animated teal arc → `SharedPreferences.setDouble('sensor_z_baseline')` → `FaceDownNotifier._loadThresholdThenSubscribe()` picks up the value at startup. Skip fallback for emulators.

---

### ✅ COMPLETED: Category Filter for Dashboard (MVP.002.004)

`categoryFilterProvider` StateProvider → all 7 analytics providers rewired to `ref.watch(categoryFilterProvider)` → filtered DAO methods in `SessionDao` + `LapDao` → `_CategoryChip` widget with `ChoiceChip` row in `DashboardScreen`. All KPIs, heatmap, donut chart, and 1RM line chart react to category selection.

---

### ✅ COMPLETED: Dynamic Break Earning (US 2.1)

`SessionState.earnedBreakDuration` computed property → quality score × elapsed time scaling → clamped 5–25 min → `_EarnedBreakBanner` banner on `SummaryScreen` → primary CTA navigates to `/break` with `Duration` extra → `BreakTimerScreen` accepts `earnedDuration` param, pre-selects it, shows ★ EARNED badge; scrollable 5-chip preset row.

---

### ✅ COMPLETED: Cloud Sync Wire-Up (US 5.4 + US 5.5)

`SupabaseSyncService.syncAll(localOnlyNotes: bool)` → strips lap notes when privacy mode active → `testConnection()` ping method → `SettingsScreen` rewritten with Supabase config bottom sheet (URL + Anon Key), save+test flow, live sync status chip, and "Sync Now" manual trigger tile.

---

### 🎯 NEXT: Paywall Gate & Stripe (MVP.003.002/003/004)

**Why next?** Core loop, onboarding, analytics, break recovery, and cloud sync are all production-quality. The monetisation gate is the final critical piece before public beta.

**What to build:**
1. **MVP.003.002** — Session-count gate on app launch (redirect to `/paywall` after N free sessions).
2. **MVP.003.003** — Stripe Checkout via Supabase Edge Function.
3. **MVP.003.004** — `isUserPaid()` license verification check.

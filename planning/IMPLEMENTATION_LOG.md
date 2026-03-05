# NeuroLoad — Implementation Log
**Last Updated:** 2026-03-05 (Full audit pass — stale rows removed, silent gaps added, Sprint 4 defined)
**Author:** AI Engineering Assistant
**Purpose:** Single source of truth for implementation status, audit findings, and next sprint tasks.
**Audit Report:** Full source-verified breakdown → `runway/AUDIT_REPORT.md`

---

## Legend
- ✅ **DONE** — Fully implemented, source-verified
- 🔨 **PARTIAL** — Shell exists, specific piece confirmed missing in source
- ❌ **NOT STARTED** — No code exists
- 🔒 **BLOCKED** — Waiting on a prerequisite
- ⚠️ **STALE** — Bug/feature written against a design that was never built

---

## ─────────────────────────────────────────────
## EPIC 0 — Onboarding
## ─────────────────────────────────────────────

| Story | Title | Status | Source-Verified Notes |
|-------|-------|--------|-----------------------|
| MVP.000.001 | The Manifesto Screen | ✅ DONE | Typewriter animation, scroll-to-unlock, `has_completed_onboarding` flag in `onboarding_screen.dart` |
| MVP.000.002 | Lap Mechanic Tutorial | ✅ DONE | Interactive mock DISTRACTED button, tap-to-proceed in `_LapTutorialPage` |
| MVP.000.003 | Sensor Calibration | 🔨 PARTIAL | 3-phase idle→sampling→done, live Z readout, arc painter, haptic, baseline saved to SharedPrefs ✅. **Missing: 4th "testing" phase** — user never asked to flip phone to confirm threshold works. See Sprint 4. |
| MVP.000.004 | Intent Statement Practice | ✅ DONE | TextField + 10-char min validation in `_IntentPracticePage` |
| MVP.000.005 | Baseline Test (5-min timer) | ✅ DONE | Full embedded countdown, lap counter, `SessionDao.insertSession` + `finishSession` on complete, Skip link |
| MVP.000.006 | Founder's Oath / Privacy Overview | ✅ DONE | 4 `_PrivacyPoint` entries incl. flow-state promise (Bug 11), "I Agree" sets flag + routes to `/setup` |

---

## ─────────────────────────────────────────────
## EPIC 1 — Core Timer & Session Management
## ─────────────────────────────────────────────

| Story | Title | Status | Source-Verified Notes |
|-------|-------|--------|-----------------------|
| MVP.001.001 | Start Session Manually | ✅ DONE | Category selector gates Start; `startSession()` writes Drift row, navigates `/timer` |
| MVP.001.002 | Start via Face-Down Trigger | ✅ DONE | `faceDownStartProvider` → haptic confirm → auto-start in setup screen |
| MVP.001.003 | Breathing Ring | ✅ DONE | `BreathingRing` custom painter, 10s sine pulse, continuous |
| MVP.001.004 | Ambient Display / Hide Timer | ✅ DONE | Double-tap toggles `AnimatedOpacity` on clock text |
| MVP.001.005 | Distracted Button | ✅ DONE | 88dp, `HapticFeedback.heavyImpact()`, lap appended to state |
| MVP.001.006 | Distraction Classification Modal | ✅ DONE | `DistractionModal` — 6 icons, 5s progress bar |
| MVP.001.007 | Lap Text Field (4-word note) | ✅ DONE | Word-count validation, optional note saved to `Lap` |
| MVP.001.008 | 5-Second Auto-Dismiss | ✅ DONE | `Future.delayed(5s)` → `DistractionTrigger.involuntary` default |
| MVP.001.009 | End Session (Long-Press Finish) | ✅ DONE | `LongPressFinishButton` — 2s hold, animated fill ring |
| MVP.001.010 | Quality Score Calculation | ✅ DONE | `qualityScore` = density − lap penalty × `durationMultiplier`; persisted on finish (Bug 02 fixed) |
| MVP.001.011 | Post-Session Summary Screen | ✅ DONE | Quality card, 1RM, density, lap count, top trigger on `SummaryScreen` |
| MVP.001.012 | Zombie Session Guardrail | ✅ DONE | `zombieSessionProvider` → `findIncomplete()` → `AppShell._checkZombie()` |
| MVP.001.013 | Recovery Modal | ✅ DONE | `ZombieRecoveryModal` — Resume / 2-step Discard, `resumeZombieSession()` |
| US 1.2 | Sub-Category Auto-Suggest | 🔨 PARTIAL | TextField exists. **Top-5 historical suggestions from DB not implemented.** See Sprint 5. |
| US 1.3 | Baseline Aim (+5% PB Nudge) | 🔨 PARTIAL | Target duration stored in state. **"+5% from last 3 sessions" display on setup screen not implemented.** See Sprint 5. |
| US 1.9 | Haptic Milestones | ✅ DONE | `_checkHapticMilestone()` — `lightImpact()` every 600s |
| US 2.4 | "One More Rep" Nudge | ❌ NOT STARTED | `LongPressFinishButton.onFinished` goes straight to finish. No PB proximity check before completing. |
| US 4.8 | Ghost Intent Flash on Modal Timeout | ❌ NOT STARTED | Modal auto-dismisses after 5s but never flashes session intent before closing. |

---

## ─────────────────────────────────────────────
## EPIC 2 — Local Analytics & Dashboard
## ─────────────────────────────────────────────

| Story | Title | Status | Source-Verified Notes |
|-------|-------|--------|-----------------------|
| MVP.002.001 | 24-Hour Circular Focus Ring | ✅ DONE | `_CircularHeatmap` CustomPainter, 24-segment clock ring, arc width+opacity by focus minutes, peak-hour label, tap-toggle to 90-day grid |
| MVP.002.002 | 1RM Tracking | ✅ DONE | `allTimeOneRmProvider`, KPI card, `_OneRMLineChart` progression |
| MVP.002.003 | Distraction Trigger Breakdown | ✅ DONE | `_DistractionDoughnut` via `fl_chart`, `triggerCountMapProvider` |
| MVP.002.004 | Category Filter | ✅ DONE | `categoryFilterProvider` → all 7 providers filtered → `ChoiceChip` row |
| US 3.2 | Distraction Danger Zones | ❌ NOT STARTED | Heatmap shows focus time only. No lap-density overlay or danger-zone highlighting. |
| US 3.3 | Focus Density KPI | ✅ DONE | `avgFocusDensityProvider` KPI card |
| US 3.4 | Resilience KPI | ❌ NOT STARTED | `Lap.lapDurationSeconds` is time between laps, not modal-dismiss delta. No tracking, no UI card. |
| US 3.8 | Trophy Room | ✅ DONE | `TrophyRoomScreen` at `/trophies`, top 5 by 1RM |
| US 4.1 | Coach — Baseline Gate | ✅ DONE | `CoachEngine._baselineThreshold = 10`; progress text until unlocked |
| US 4.2 | Coach — +5% Next Aim | ✅ DONE | `nextAimSuggestion` generated post-baseline |
| US 4.3 | Coach — De-load Warning | ✅ DONE | >15pt quality drop over 3 sessions → `deloadWarning` |
| US 4.x | Coach — PB Detection | ✅ DONE | Latest 1RM == all-time 1RM → "New All-Time 1RM!" insight |
| US 4.x | Coach — Distraction Pattern | ✅ DONE | Top trigger + percentage insight |
| US 4.4 | Coach — Contextual Leak | ❌ NOT STARTED | Cross-category 1RM delta analysis not in `CoachEngine`. |
| US 4.5 | Coach — Strategy Recommendations | ❌ NOT STARTED | Static mitigation map not implemented. |

---

## ─────────────────────────────────────────────
## EPIC 3 — Monetisation & Licensing
## ─────────────────────────────────────────────

| Story | Title | Status | Source-Verified Notes |
|-------|-------|--------|-----------------------|
| MVP.003.001 | Dynamic Pricing Display | 🔨 PARTIAL | `PaywallScreen` built, €49 hardcoded. **Supabase-dynamic pricing not wired.** |
| MVP.003.002 | Forced Paywall After One Session | ✅ DONE | `paywallGateProvider` + GoRouter redirect; `freeSessionsUsedProvider` incremented on finish |
| MVP.003.003 | Stripe Checkout Integration | ❌ NOT STARTED | "Buy Now" is a SnackBar stub. No Supabase Edge Function, no URL launch. |
| MVP.003.004 | License Status Verification | ✅ DONE | `isPaidProvider`, PLUS/FREE chip, voucher redemption stub |
| MVP.003.005 | GDPR Data Export | ✅ DONE | `ExportService.exportAllData()` → `share_plus` → sessions.csv + laps.csv |
| MVP.003.006 | GDPR Wipe Data | ✅ DONE | Laps → sessions delete, `SharedPreferences.clear()`, in-memory reset |

---

## ─────────────────────────────────────────────
## EPIC 5 — Security & Privacy
## ─────────────────────────────────────────────

| Story | Title | Status | Source-Verified Notes |
|-------|-------|--------|-----------------------|
| US 5.1 | Local-First Storage (Drift) | ✅ DONE | All data in Drift SQLite, no cloud write on default |
| US 5.3 | Data Export | ✅ DONE | See MVP.003.005 |
| US 5.4 | Cloud Sync (Opt-In) | ✅ DONE | `SupabaseSyncService.syncAll()`, credentials bottom sheet, status chip |
| US 5.5 | Strict Privacy Toggle | ✅ DONE | `localOnlyNotes` nullifies lap notes before upload |

---

## ─────────────────────────────────────────────
## EPIC 7 — Hardware & System Polish
## ─────────────────────────────────────────────

| Story | Title | Status | Source-Verified Notes |
|-------|-------|--------|-----------------------|
| US 2.1 | Dynamic Break Earning | ✅ DONE | `earnedBreakDuration` computed; `_EarnedBreakBanner` on Summary; `/break` GoRoute |
| US 2.2 | Break UI Color Shift | ✅ DONE | `BreakTimerScreen` uses teal/sage palette |
| US 2.3 | Break Notifications | ❌ NOT STARTED | `NotificationService.showRestComplete()` exists but is **never called** from `BreakTimerScreen`. T-60s chime also missing. |
| US 7.1 | Lap Feed UI | ✅ DONE | `LapFeed` with `ListView.builder`, trigger emoji + note |
| US 7.3 | Adaptive Sensor Polling | ✅ DONE | 200ms active / 2000ms idle, stream recreated on phase change |
| US 7.4 | Live Activities (iOS) | ❌ NOT STARTED | Requires native Swift ActivityKit. Deferred. |
| US 7.5 | Foreground Service (Android) | ✅ DONE | `flutter_foreground_task`, `ForegroundTaskHandler`, tick→main isolate, `AndroidManifest.xml` |

---

## ─────────────────────────────────────────────
## EPIC 9 — Phase 2 / 3 / 4 Backlog
## ─────────────────────────────────────────────

| Story | Title | Phase | Status |
|-------|-------|-------|--------|
| US 9.1 | Invoice Generation (Resend API) | 2 | ❌ NOT STARTED |
| US 9.2 | Calendar Task Import | 2 | ❌ NOT STARTED |
| US 9.3 | Circadian Rhythm Analysis | 2 | ❌ NOT STARTED |
| US 9.4 | Ghost Intent Reminder | 2 | ❌ NOT STARTED |
| US 9.5 | Next.js B2B Web Portal | 3 | ❌ NOT STARTED |
| US 9.6 | Smart Coach ML (ARIMA) | 3 | ❌ NOT STARTED |
| US 9.7 | NeuroLoad Plus Upsell | 3 | ❌ NOT STARTED |
| US 9.8 | Dyslexia-Friendly Typography (OpenDyslexic) | 3 | ❌ NOT STARTED |
| US 9.9 | Screen-Reader & VoiceOver | 3 | ❌ NOT STARTED |
| US 9.10 | Soundscape Engine | 4 | ❌ NOT STARTED |
| US 9.11 | Study Lounges & Battles | 4 | ❌ NOT STARTED |
| US 9.12 | Global Focus Leaderboards | 4 | ❌ NOT STARTED |
| US 9.13 | Focus Resume PDF Export | 4 | ❌ NOT STARTED |

---

## ─────────────────────────────────────────────
## BUG FIX LOG
## ─────────────────────────────────────────────

| Bug | Title | True Status | Method / Notes |
|-----|-------|-------------|----------------|
| Bug 01 | Long Session Saving | ✅ FIXED | `_autoSaveProgress()` every 300 ticks → `SessionDao.updateElapsed()` UPDATE-only |
| Bug 02 | Quality Score Inflation | ✅ FIXED | `durationMultiplier = elapsed / 300s` applied to raw score for sub-5-min sessions |
| Bug 03 | Pause Logic Too Generous | ⚠️ STALE | No pause feature or phase exists in codebase. `SessionPhase` = idle/active/rest/complete. Closing as WONTFIX. |
| Bug 04 | Language Selection | ❌ DEFERRED | No i18n system. Requires `flutter_localizations` + ARB files + language page in onboarding. Phase 2. |
| Bug 05 | Sporadic DB Write Failure | ✅ FIXED | `PendingSessionStore` queues payload to SharedPrefs on catch; `AppShell._flushPendingSession()` retries on launch |
| Bug 06 | High Contrast Non-Functional | 🔨 PARTIAL | Theme rebuilds wired ✅. **Font picker tile `onTap: () {}` stub — no picker UI.** Sprint 4. |
| Bug 07 | About Section Links | ✅ FIXED (MVP) | `url_launcher`, `_launchUrl()`, 3 URLs wired. Locale-aware URLs blocked by Bug 04. |
| Bug 08 | Flip Calibration UX | 🔨 PARTIAL | 3-phase flow + arc + haptic ✅. **4th testing phase (flip-to-confirm) missing.** Sprint 4. |
| Bug 09 | Lock Screen Widget | 🔨 PARTIAL | Android `AndroidNotificationAction` + callback wired ✅. iOS ActivityKit deferred. |
| Bug 10 | Auto-Distraction on Flip-Up | ✅ FIXED | `FaceDownNotifier._onEvent` → `addLap(phone, 'auto: phone flipped up')` when phase==active |
| Bug 11 | Flow State Promise | ✅ FIXED | 4th `_PrivacyPoint` in `_FounderOathPage` with `Icons.psychology_outlined` |

---

## ─────────────────────────────────────────────
## AUDIT — SILENT GAPS (found 2026-03-05)
## These were never tracked. Now formally logged.
## ─────────────────────────────────────────────

| ID | Gap | File | Priority |
|----|-----|------|----------|
| GAP-001 | `settingsProvider` is **in-memory only** — high contrast + font selection lost on every app restart | `lib/providers/session_provider.dart` → `SettingsNotifier` | 🔴 P1 |
| GAP-002 | **Font picker tile** has `onTap: () {}` — user can toggle high contrast but cannot select a font | `lib/screens/settings/settings_screen.dart` line ≈195 | 🔴 P1 |
| GAP-003 | **`/timer` route guard missing** — navigating to `/timer` with no active session shows a blank/broken screen | `lib/router.dart` | 🔴 P1 |
| GAP-004 | **`NotificationService.showRestComplete()`** exists but is never called from `BreakTimerScreen` (US 2.3) | `lib/screens/break/break_timer_screen.dart` | 🟡 P1 |
| GAP-005 | **"One More Rep" nudge** (US 2.4) — `LongPressFinishButton.onFinished` has no PB proximity check | `lib/screens/timer/timer_screen.dart` `_finishSession()` | 🟡 P1 |
| GAP-006 | **Ghost Intent flash** (US 4.8) — `DistractionModal` auto-dismiss does not flash intent before closing | `lib/screens/timer/widgets/distraction_modal.dart` | 🟡 P1 |
| GAP-007 | **Sub-category auto-suggest** (US 1.2) — plain TextField, no DB history lookup | `lib/screens/setup/setup_screen.dart` | 🟢 P2 |
| GAP-008 | **Baseline Aim +5% nudge display** (US 1.3) — target duration in state, setup screen doesn't show PB-based suggestion | `lib/screens/setup/setup_screen.dart` | 🟢 P2 |
| GAP-009 | **Resilience KPI** (US 3.4) — `Lap.lapDurationSeconds` is lap-to-lap, not modal-dismiss delta. No UI card. | `lib/data/tables.dart`, `lib/providers/session_provider.dart` | 🟢 P2 |
| GAP-010 | **Distraction Danger Zones** (US 3.2) — heatmap shows focus time only, no lap-density overlay | `lib/screens/dashboard/dashboard_screen.dart` | 🟢 P2 |
| GAP-011 | **Contextual Leak coach insight** (US 4.4) — cross-category 1RM delta not in `CoachEngine` | `lib/services/coach_engine.dart` | 🟢 P2 |
| GAP-012 | **Strategy Recommendations** (US 4.5) — static mitigation text map not implemented | `lib/services/coach_engine.dart` | 🟢 P2 |

---

## ─────────────────────────────────────────────
## STALE LOG ENTRIES — CORRECTED
## Items that were WRONG in previous log versions
## ─────────────────────────────────────────────

| Old Entry | Was Claimed | Reality |
|-----------|-------------|---------|
| Key Technical Gaps — "Heatmap is daily grid" | 🔴 HIGH gap | ✅ FIXED — `_CircularHeatmap` CustomPainter done as MVP.002.001 |
| Key Technical Gaps — "Adaptive sensor polling not throttled" | 🟢 LOW gap | ✅ FIXED — US 7.3 implemented, 200ms/2000ms switching live |
| Key Technical Gaps — "Paywall gate not wired to app startup" | 🔴 HIGH gap | ✅ FIXED — MVP.003.002 done, GoRouter redirect active |
| EPIC 8 note — "Calibration missing sensor reads" | ❌ missing | ✅ FIXED — full live stream + 3-sample avg + SharedPrefs write implemented |
| EPIC 8 note — "Baseline test should save to DB" | ❌ missing | ✅ FIXED — `insertSession` + `finishSession` called in `_BaselineTestPageState` |

---

## ─────────────────────────────────────────────
## SPRINT 4 — CURRENT DEVELOPMENT TARGET
## Start here. Complete all P0 items before moving to P1.
## ─────────────────────────────────────────────

**Goal:** Ship everything blocking a clean public beta build. No new features — only blockers and critical gaps.

---

### 🔴 S4-001 — Stripe Checkout (MVP.003.003)
**Effort:** 8–10 days  **Blocks:** Revenue, public beta

| Task | File | Detail |
|------|------|--------|
| S4-001-A | Supabase Dashboard | Create Edge Function `create-checkout-session`: accept `user_id`, call Stripe API, return `{url}` |
| S4-001-B | Supabase Dashboard | Create Edge Function `handle-stripe-webhook`: verify Stripe signature, set `has_paid = true` on `users` table |
| S4-001-C | `lib/screens/paywall/paywall_screen.dart` | Wire "Buy Now" `onTap` → POST to `create-checkout-session` → `launchUrl(checkoutUrl)` |
| S4-001-D | `lib/providers/subscription_provider.dart` | After `launchUrl`, poll `isPaidProvider` every 3s for up to 60s; on `true` → dismiss paywall |
| S4-001-E | `runway/SECRETS_CHECKLIST.md` | Add `STRIPE_PUBLISHABLE_KEY` to GitHub Secrets; add `STRIPE_SECRET_KEY` to Supabase secrets only |

**Acceptance criteria:** Tapping "Buy Now" opens Stripe Checkout in browser. Completing payment updates `isPaidProvider` to `true` and dismisses the paywall without requiring app restart.

---

### 🔴 S4-002 — Bug 08: Calibration Live Test Phase
**Effort:** 1 day  **Blocks:** Correct onboarding UX for all users

| Task | File | Detail |
|------|------|--------|
| S4-002-A | `lib/screens/onboarding/onboarding_screen.dart` | Add `_CalibrationPhase.testing` to the enum (after `done`) |
| S4-002-B | same | In `_finishCalibration()`, after saving baseline, set phase to `testing` instead of `done` |
| S4-002-C | same | In `testing` phase: subscribe to accelerometer using saved `_zThreshold`. If `e.z <= _zThreshold` for 1500ms → haptic + set phase to `done` + call `onCalibrated()` |
| S4-002-D | same | `_buildVisual()` testing branch: show "Now flip it face-down to confirm" text + pulsing phone icon |
| S4-002-E | same | Add "Skip test" link in testing phase (same as existing skip link) |

**Acceptance criteria:** After baseline sampling, user sees a prompt to flip phone face-down. Holding it down for 1.5s produces green checkmark + haptic and unlocks Continue. Skip link always available.

---

### 🔴 S4-003 — GAP-001: Persist settingsProvider to SharedPreferences
**Effort:** 1 day  **Blocks:** High contrast + font preferences lost on restart

| Task | File | Detail |
|------|------|--------|
| S4-003-A | `lib/providers/session_provider.dart` → `SettingsNotifier` | On construction, load `highContrast`, `localOnlyNotes`, `cloudSyncEnabled`, `fontFamily` from `SharedPreferences` |
| S4-003-B | same | In every `toggle*` and `setFont()` method, write updated value back to `SharedPreferences` after updating state |
| S4-003-C | same | Keys: `settings_high_contrast` (bool), `settings_local_only_notes` (bool), `settings_cloud_sync` (bool), `settings_font_family` (String) |

**Acceptance criteria:** Toggle high contrast → kill app → reopen → high contrast still active.

---

### 🔴 S4-004 — GAP-002: Font Picker UI
**Effort:** 0.5 days  **Blocks:** Bug 06 full resolution

| Task | File | Detail |
|------|------|--------|
| S4-004-A | `lib/screens/settings/settings_screen.dart` | Replace `onTap: () {}` on Font tile with `_showFontPicker(context)` |
| S4-004-B | same | `_showFontPicker()` → `showModalBottomSheet` with 3 options: `Inter` (default), `Georgia` (serif), `Courier` (monospace) |
| S4-004-C | same | Each option: `ListTile` with font name rendered in that font + checkmark if selected |
| S4-004-D | same | On selection: `ref.read(settingsProvider.notifier).setFont(family)` — theme rebuilds automatically |

**Acceptance criteria:** Tapping Font tile shows picker. Selecting a font immediately updates all body text across the app. Selection survives restart (depends on S4-003).

---

### 🔴 S4-005 — GAP-003: `/timer` Route Guard
**Effort:** 0.5 days  **Blocks:** Crash/blank screen for direct navigation

| Task | File | Detail |
|------|------|--------|
| S4-005-A | `lib/router.dart` | In the `/timer` route `redirect` callback: if `sessionProvider.phase != SessionPhase.active` → redirect to `/setup` |
| S4-005-B | same | Same guard for `/summary` — if `phase != SessionPhase.complete` → redirect to `/setup` |

**Acceptance criteria:** Opening `/timer` URL with no active session redirects cleanly to `/setup`. No blank screen.

---

### 🟡 S4-006 — GAP-004: Break Notifications (US 2.3)
**Effort:** 1 day

| Task | File | Detail |
|------|------|--------|
| S4-006-A | `lib/screens/break/break_timer_screen.dart` | When `_remaining == 60` inside the countdown ticker, call `NotificationService.showRestComplete()` with a "1 minute left" title |
| S4-006-B | same | When `_remaining == 0`, call `NotificationService.showRestComplete()` with "Break over — time to train" title |
| S4-006-C | `lib/services/notification_service.dart` | Update `showRestComplete()` to accept a `title` and `body` parameter instead of hardcoded strings |

**Acceptance criteria:** Phone locked during break: at T-60s a notification appears "1 minute left"; at T-0 "Break over — time to train" appears.

---

### 🟡 S4-007 — GAP-005: "One More Rep" Nudge (US 2.4)
**Effort:** 0.5 days

| Task | File | Detail |
|------|------|--------|
| S4-007-A | `lib/screens/timer/timer_screen.dart` `_finishSession()` | Before calling `finishSession()`, fetch `allTimeOneRmProvider` |
| S4-007-B | same | Compute `currentLapDuration` = elapsed since last lap (or session start if 0 laps) |
| S4-007-C | same | If `currentLapDuration >= allTimeOneRm * 0.9` (within 10%): show `AlertDialog` "You are X min from your PB. Keep going?" with "Keep Going" / "End Anyway" actions |
| S4-007-D | same | "Keep Going" pops the dialog only; "End Anyway" proceeds with `finishSession()` |

**Acceptance criteria:** Finishing a session while within 10% of all-time 1RM triggers the nudge dialog. Dismissing it resumes the timer. Confirming ends the session normally.

---

### 🟡 S4-008 — GAP-006: Ghost Intent Flash (US 4.8)
**Effort:** 0.5 days

| Task | File | Detail |
|------|------|--------|
| S4-008-A | `lib/screens/timer/widgets/distraction_modal.dart` | In the 5s auto-dismiss `Future.delayed`, change to: at 3.5s set state `_showingIntent = true` (shows intent text), then at 5s pop |
| S4-008-B | same | Add `_showingIntent` bool to modal state. When true, replace icon grid with centered intent text (italic, teal, fade-in `AnimatedOpacity`) |
| S4-008-C | same | Intent is already passed in as `widget.intent` — no provider read needed |

**Acceptance criteria:** Tapping Distracted and doing nothing → at 3.5s the 6 icons fade out and the session intent text appears for 1.5s → modal closes and `Involuntary` lap is logged.

---

## ─────────────────────────────────────────────
## SPRINT 5 — QUEUED (start after Sprint 4 ships)
## ─────────────────────────────────────────────

| ID | Item | Effort | File |
|----|------|--------|------|
| S5-001 | US 1.2 Sub-category auto-suggest | 1 day | `setup_screen.dart` + `SessionDao.topSubCategories(category, limit: 5)` |
| S5-002 | US 1.3 Baseline aim +5% nudge display | 1 day | `setup_screen.dart` reads `nextAimProvider`, pre-fills target |
| S5-003 | US 3.4 Resilience KPI tracking | 1 day | Add `modalOpenedAt` timestamp to Lap, compute delta on dismiss, new `avgResilienceProvider` + KPI card |
| S5-004 | US 4.4 + US 4.5 Contextual Leak + Mitigation text | 1 day | `coach_engine.dart` — cross-category 1RM delta; static mitigation map |
| S5-005 | US 3.2 Distraction Danger Zones on heatmap | 2 days | `dashboard_screen.dart` — second ring or overlay on `_CircularHeatmap` for lap density |
| S5-006 | Bug 04 / Bug 07: Full i18n system | 3 days | `pubspec.yaml` + `lib/l10n/` ARB files + `LanguageSelectionPage` in onboarding |
| S5-007 | Bug 09 iOS: ActivityKit Live Activities | 5 days | Native Swift widget + Flutter method channel (requires Mac + Apple Developer account) |

---

## ─────────────────────────────────────────────
## CI/CD STATUS
## ─────────────────────────────────────────────

Live as of 2026-03-05. See `runway/GUIDE.md` for full setup.

| File | Runner | What it does |
|------|--------|--------------|
| `.github/workflows/ci_android.yml` | ubuntu-latest | analyze + test on every PR; APK + AAB on push to main |
| `.github/workflows/ci_ios.yml` | macos-latest | analyze + test on every PR; unsigned IPA on push to main |
| `android/app/build.gradle.kts` | — | Reads `android/key.properties` for release signing; falls back to debug if absent |

**One-time setup required:** Add 4 Android secrets to GitHub → `KEYSTORE_BASE64`, `KEY_ALIAS`, `KEY_PASSWORD`, `STORE_PASSWORD`. See `runway/SECRETS_CHECKLIST.md`.

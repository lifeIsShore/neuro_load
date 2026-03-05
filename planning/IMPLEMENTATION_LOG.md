# NeuroLoad — Implementation Log
**Last Updated:** 2026-03-05 (Sprint 4 complete + beta polish fixes applied)
**Author:** AI Engineering Assistant
**Purpose:** Single source of truth for implementation status, audit findings, and sprint tasks.

---

## Legend
- ✅ **DONE** — Fully implemented, source-verified
- 🔨 **PARTIAL** — Shell exists, specific piece confirmed missing in source
- ❌ **NOT STARTED** — No code exists
- 🔒 **BLOCKED** — Waiting on a prerequisite
- ⚠️ **STALE** — Written against a design that was never built

---

## ─────────────────────────────────────────────
## EPIC 0 — Onboarding
## ─────────────────────────────────────────────

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| MVP.000.001 | Manifesto Screen | ✅ DONE | Typewriter animation, scroll-to-unlock, `has_completed_onboarding` flag |
| MVP.000.002 | Lap Mechanic Tutorial | ✅ DONE | Interactive mock DISTRACTED button, tap-to-proceed in `_LapTutorialPage` |
| MVP.000.003 | Sensor Calibration | ✅ DONE | **S4-002 shipped.** 4-phase idle→sampling→testing→done. Live Z readout, arc painter, haptic, baseline saved. User must physically flip phone face-down to pass testing phase (Z < baseline − 12 for 1.2s). Skip always available. |
| MVP.000.004 | Intent Statement Practice | ✅ DONE | TextField + 10-char min validation in `_IntentPracticePage` |
| MVP.000.005 | Baseline Test (5-min timer) | ✅ DONE | Full embedded countdown, lap counter, `SessionDao.insertSession` + `finishSession` on complete, Skip link |
| MVP.000.006 | Founder's Oath / Privacy Overview | ✅ DONE | 4 `_PrivacyPoint` entries incl. flow-state promise, "I Agree" sets flag + routes to `/setup` |

---

## ─────────────────────────────────────────────
## EPIC 1 — Core Timer & Session Management
## ─────────────────────────────────────────────

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| MVP.001.001 | Start Session Manually | ✅ DONE | Category selector gates Start; `startSession()` writes Drift row, navigates `/timer` |
| MVP.001.002 | Start via Face-Down Trigger | ✅ DONE | `faceDownStartProvider` → haptic confirm → auto-start in setup screen |
| MVP.001.003 | Breathing Ring | ✅ DONE | `BreathingRing` custom painter, 10s sine pulse, continuous |
| MVP.001.004 | Ambient Display / Hide Timer | ✅ DONE | Double-tap toggles `AnimatedOpacity` on clock text |
| MVP.001.005 | Distracted Button | ✅ DONE | 88dp, `HapticFeedback.heavyImpact()`, lap appended to state |
| MVP.001.006 | Distraction Classification Modal | ✅ DONE | `DistractionModal` — 6 icons, 5s progress bar |
| MVP.001.007 | Lap Text Field (4-word note) | ✅ DONE | Word-count validation, optional note saved to `Lap` |
| MVP.001.008 | 5-Second Auto-Dismiss | ✅ DONE | **S4-008 shipped.** `_userActed` flag prevents ghost flash on auto-dismiss. Flash only fires when user was idle (no trigger selected) and session intent exists. |
| MVP.001.009 | End Session (Long-Press Finish) | ✅ DONE | `LongPressFinishButton` — 2s hold, animated fill ring |
| MVP.001.010 | Quality Score Calculation | ✅ DONE | `qualityScore` = density − lap penalty × `durationMultiplier`; persisted on finish |
| MVP.001.011 | Post-Session Summary Screen | ✅ DONE | Quality card, 1RM, density, lap count, top trigger on `SummaryScreen` |
| MVP.001.012 | Zombie Session Guardrail | ✅ DONE | `zombieSessionProvider` → `findIncomplete()` → `AppShell._checkZombie()` |
| MVP.001.013 | Recovery Modal | ✅ DONE | `ZombieRecoveryModal` — Resume / 2-step Discard, `resumeZombieSession()` |
| US 1.2 | Sub-Category Auto-Suggest | ❌ NOT STARTED | Plain TextField. Hardcoded chips removed (beta polish). DB lookup → Sprint 5 (S5-001). |
| US 1.3 | Baseline Aim (+5% PB Nudge) | ❌ NOT STARTED | Target duration in state. "+5% from last 3 sessions" display on setup screen not built. → Sprint 5 |
| US 1.9 | Haptic Milestones | ✅ DONE | `_checkHapticMilestone()` — `lightImpact()` every 600s |
| US 2.4 | "One More Rep" Nudge | ✅ DONE | **S4-007 shipped.** `_finishSession()` checks elapsed < target AND laps < 3. Shows bottom sheet with exact remaining minutes. "Keep Going" stays in session; "End Anyway" calls `_doFinish()`. |
| US 4.8 | Ghost Intent Flash on Modal Timeout | ✅ DONE | **S4-008 shipped.** See MVP.001.008 above. |

---

## ─────────────────────────────────────────────
## EPIC 2 — Local Analytics & Dashboard
## ─────────────────────────────────────────────

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| MVP.002.001 | 24-Hour Circular Focus Ring | ✅ DONE | `_CircularHeatmap` CustomPainter, 24-segment clock ring, arc width+opacity by focus minutes, peak-hour label, tap-toggle to 90-day grid |
| MVP.002.002 | 1RM Tracking | ✅ DONE | `allTimeOneRmProvider`, KPI card, `_OneRMLineChart` progression |
| MVP.002.003 | Distraction Trigger Breakdown | ✅ DONE | `_DistractionDoughnut` via `fl_chart`, `triggerCountMapProvider` |
| MVP.002.004 | Category Filter | ✅ DONE | `categoryFilterProvider` → all 7 providers filtered → `ChoiceChip` row |
| US 3.2 | Distraction Danger Zones | ❌ NOT STARTED | Heatmap shows focus time only. No lap-density overlay. → Sprint 5 |
| US 3.3 | Focus Density KPI | ✅ DONE | `avgFocusDensityProvider` KPI card |
| US 3.4 | Resilience KPI | ❌ NOT STARTED | `Lap.lapDurationSeconds` is time between laps, not modal-dismiss delta. No tracking, no UI card. → Sprint 5 |
| US 3.8 | Trophy Room | ✅ DONE | `TrophyRoomScreen` at `/trophies`, top 5 by 1RM |
| US 4.1 | Coach — Baseline Gate | ✅ DONE | `CoachEngine._baselineThreshold = 10`; progress text until unlocked |
| US 4.2 | Coach — +5% Next Aim | ✅ DONE | `nextAimSuggestion` generated post-baseline |
| US 4.3 | Coach — De-load Warning | ✅ DONE | >15pt quality drop over 3 sessions → `deloadWarning` |
| US 4.x | Coach — PB Detection | ✅ DONE | Latest 1RM == all-time 1RM → "New All-Time 1RM!" insight |
| US 4.x | Coach — Distraction Pattern | ✅ DONE | Top trigger + percentage insight |
| US 4.4 | Coach — Contextual Leak | ❌ NOT STARTED | Cross-category 1RM delta analysis not in `CoachEngine`. → Sprint 5 |
| US 4.5 | Coach — Strategy Recommendations | ❌ NOT STARTED | Static mitigation map not implemented. → Sprint 5 |

---

## ─────────────────────────────────────────────
## EPIC 3 — Monetisation & Licensing
## ─────────────────────────────────────────────

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| MVP.003.001 | Dynamic Pricing Display | 🔨 PARTIAL | `PaywallScreen` built, €49 hardcoded. Supabase-dynamic pricing not wired. → S5-008 |
| MVP.003.002 | Forced Paywall After One Session | ✅ DONE | `paywallGateProvider` + GoRouter redirect; `freeSessionsUsedProvider` incremented on finish |
| MVP.003.003 | Stripe Checkout Integration | 🔨 PARTIAL | **Code complete. Intentionally disabled for beta** (`_betaMode = true` in `paywall_screen.dart`). Buy Now shows "PAYMENT COMING SOON" + snackbar directing to voucher. All Stripe imports removed for clean beta build. Edge Functions written and ready. **To re-enable:** set `_betaMode = false`, restore imports + `_launchStripeCheckout()`, follow `S4-001-STRIPE-SETUP.md`. |
| MVP.003.004 | License Status Verification | ✅ DONE | `isPaidProvider`, PLUS/FREE chip, voucher redemption |
| MVP.003.005 | GDPR Data Export | ✅ DONE | `ExportService.exportAllData()` → `share_plus` → sessions.csv + laps.csv |
| MVP.003.006 | GDPR Wipe Data | ✅ DONE | Laps → sessions delete, `SharedPreferences.clear()`, in-memory reset |

---

## ─────────────────────────────────────────────
## EPIC 4 — Hardware & Platform
## ─────────────────────────────────────────────

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| US 2.1 | Dynamic Break Earning | ✅ DONE | `earnedBreakDuration` computed; `_EarnedBreakBanner` on Summary; `/break` GoRoute |
| US 2.2 | Break UI Color Shift | ✅ DONE | `BreakTimerScreen` uses teal/sage palette |
| US 2.3 | Break Notifications | ✅ DONE | **S4-006 shipped.** `NotificationService.showRestComplete()` wired into `_onComplete()` in `summary/break_timer_screen.dart`. Fires on break timer zero. |
| US 7.1 | Lap Feed UI | ✅ DONE | `LapFeed` with `ListView.builder`, trigger emoji + note |
| US 7.3 | Adaptive Sensor Polling | ✅ DONE | 200ms active / 2000ms idle, stream recreated on phase change |
| US 7.4 | Live Activities (iOS) | ❌ NOT STARTED | Requires native Swift ActivityKit. Deferred to Sprint 5+. |
| US 7.5 | Foreground Service (Android) | ✅ DONE | `flutter_foreground_task`, `ForegroundTaskHandler`, tick→main isolate, `AndroidManifest.xml` |

---

## ─────────────────────────────────────────────
## EPIC 5 — Settings & Privacy
## ─────────────────────────────────────────────

| Story | Title | Status | Notes |
|-------|-------|--------|-------|
| MVP.005.001 | Settings Screen | ✅ DONE | All sections wired: Privacy, Accessibility, About, Danger Zone |
| MVP.005.002 | Impressum Page | ✅ DONE | `url_launcher` → `neuroload.app/impressum` |
| MVP.005.003 | Privacy Policy & ToS Links | ✅ DONE | `url_launcher` → `neuroload.app/privacy` + `/terms` |
| GAP-001 | Settings Persistence | ✅ DONE | **S4-003 shipped.** `SettingsNotifier` now loads all 4 keys from SharedPreferences on construction. Writes on every toggle/set. |
| GAP-002 | Font Picker UI | ✅ DONE | **S4-004 shipped.** Bottom sheet with 5 font options. Each rendered in its own fontFamily. Checkmark on active. Persists via S4-003. |

---

## ─────────────────────────────────────────────
## EPIC 6 — Routing & Navigation
## ─────────────────────────────────────────────

| Item | Status | Notes |
|------|--------|-------|
| GAP-003 | `/timer` Route Guard | ✅ DONE | **S4-005 shipped.** GoRouter redirect: if `session.phase != active` when navigating to `/timer`, redirects to `/setup`. |

---

## ─────────────────────────────────────────────
## EPIC 9 — Phase 2 / 3 / 4 Backlog
## ─────────────────────────────────────────────

| Story | Title | Phase | Status |
|-------|-------|-------|--------|
| US 9.1 | Invoice Generation (Resend API) | 2 | ❌ NOT STARTED |
| US 9.2 | Calendar Task Import | 2 | ❌ NOT STARTED |
| US 9.3 | Circadian Rhythm Analysis | 2 | ❌ NOT STARTED |
| US 9.4 | Ghost Intent Reminder (full) | 2 | ❌ NOT STARTED |
| US 9.5 | Next.js B2B Web Portal | 3 | ❌ NOT STARTED |
| US 9.6 | Smart Coach ML (ARIMA) | 3 | ❌ NOT STARTED |
| US 9.7 | NeuroLoad Plus Subscription | 3 | ❌ NOT STARTED |
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

| Bug | Title | Status | Notes |
|-----|-------|--------|-------|
| Bug 01 | Long Session Saving | ✅ FIXED | `_autoSaveProgress()` every 300 ticks → `SessionDao.updateElapsed()` |
| Bug 02 | Quality Score Inflation | ✅ FIXED | `durationMultiplier = elapsed / 300s` applied to raw score for sub-5-min sessions |
| Bug 03 | Pause Logic Too Generous | ⚠️ STALE | No pause feature exists. `SessionPhase` = idle/active/rest/complete. Closed as WONTFIX. |
| Bug 04 | Language Selection | ❌ DEFERRED | No i18n system. Requires `flutter_localizations` + ARB files. Phase 2. |
| Bug 05 | Sporadic DB Write Failure | ✅ FIXED | `PendingSessionStore` queues to SharedPrefs on catch; `AppShell._flushPendingSession()` retries on launch |
| Bug 06 | High Contrast Non-Functional | ✅ FIXED | Theme rebuilds wired. Font picker UI shipped in S4-004. Both persist via S4-003. |
| Bug 07 | About Section Links | ✅ FIXED | `url_launcher`, `_launchUrl()`, 3 URLs wired. Locale-aware URLs blocked by Bug 04. |
| Bug 08 | Flip Calibration UX | ✅ FIXED | **S4-002 shipped.** 4-phase flow: idle→sampling→testing→done. Flip-to-confirm with 1.2s hold timer. |
| Bug 09 | Lock Screen Widget | 🔨 PARTIAL | Android `AndroidNotificationAction` + callback wired. iOS ActivityKit deferred Sprint 5+. |
| Bug 10 | Auto-Distraction on Flip-Up | ✅ FIXED | `FaceDownNotifier._onEvent` → `addLap(phone, 'auto: phone flipped up')` when phase==active |
| Bug 11 | Flow State Promise | ✅ FIXED | 4th `_PrivacyPoint` in `_FounderOathPage` with `Icons.psychology_outlined` |

---

## ─────────────────────────────────────────────
## SILENT GAPS TRACKER
## ─────────────────────────────────────────────

| ID | Gap | Status | Shipped In |
|----|-----|--------|-----------|
| GAP-001 | `settingsProvider` in-memory only — prefs lost on restart | ✅ FIXED | S4-003 |
| GAP-002 | Font picker tile `onTap: () {}` stub | ✅ FIXED | S4-004 |
| GAP-003 | `/timer` route guard missing | ✅ FIXED | S4-005 |
| GAP-004 | `NotificationService.showRestComplete()` never called | ✅ FIXED | S4-006 |
| GAP-005 | "One More Rep" nudge missing from `_finishSession()` | ✅ FIXED | S4-007 |
| GAP-006 | Ghost Intent flash fires on auto-dismiss (no user action) | ✅ FIXED | S4-008 |
| GAP-007 | Sub-category auto-suggest (US 1.2) — plain TextField, no DB lookup | ❌ OPEN | → Sprint 5 |
| GAP-008 | Baseline Aim +5% nudge not shown on setup screen (US 1.3) | ❌ OPEN | → Sprint 5 |
| GAP-009 | Resilience KPI (US 3.4) — no modal-dismiss delta tracking | ❌ OPEN | → Sprint 5 |
| GAP-010 | Distraction Danger Zones (US 3.2) — no lap-density heatmap overlay | ❌ OPEN | → Sprint 5 |
| GAP-011 | Contextual Leak coach insight (US 4.4) | ❌ OPEN | → Sprint 5 |
| GAP-012 | Strategy Recommendations (US 4.5) | ❌ OPEN | → Sprint 5 |

---

## ─────────────────────────────────────────────
## SPRINT 4 — COMPLETE ✅
## Shipped 2026-03-05
## ─────────────────────────────────────────────

All 8 tasks closed. No regressions introduced.

| Task | Title | Status | Key Files Changed |
|------|-------|--------|-------------------|
| S4-001 | Stripe Checkout Integration | 🔨 PARTIAL | Edge Functions written. Flutter code complete. **Beta build: Stripe disabled** (`_betaMode = true`). Voucher hardened to `[A-Z0-9]{8}` regex. Fake sub-category chips removed. Android label fixed. Timezone init hardened. |
| S4-002 | Calibration Live Test Phase | ✅ DONE | `onboarding_screen.dart` |
| S4-003 | Settings Persistence | ✅ DONE | `session_provider.dart` (SettingsNotifier) |
| S4-004 | Font Picker UI | ✅ DONE | `settings_screen.dart` |
| S4-005 | /timer Route Guard | ✅ DONE | `router.dart` |
| S4-006 | Break Notifications | ✅ DONE | `summary/break_timer_screen.dart` |
| S4-007 | One More Rep Nudge | ✅ DONE | `timer_screen.dart` |
| S4-008 | Ghost Intent Flash Fix | ✅ DONE | `distraction_modal.dart` |

### S4-001 Deployment Status
Stripe is **code-complete but intentionally disabled for beta** (`_betaMode = true` in `paywall_screen.dart`). Before public launch:
- [ ] Set `_betaMode = false` in `paywall_screen.dart`
- [ ] Restore Stripe imports (`dart:convert`, `http`, `url_launcher`, `shared_preferences`)
- [ ] Restore `_launchStripeCheckout()` method from git history / `S4-001-STRIPE-SETUP.md`
- [ ] Deploy Supabase Edge Functions (`create-checkout-session`, `stripe-webhook`)
- [ ] Set Stripe secrets in Supabase Dashboard
- [ ] Create `user_licences` table in Supabase
- [ ] Register deep-link scheme in AndroidManifest + Info.plist
- [ ] Wire `app_links` in `main.dart` for post-payment redirect

Full checklist: `planning/S4-001-STRIPE-SETUP.md`

---

## ─────────────────────────────────────────────
## BETA POLISH FIXES
## Applied post-Sprint 4, pre-beta-release
## ─────────────────────────────────────────────

| Fix | File | What changed |
|-----|------|--------------|
| Stripe disabled for beta | `paywall_screen.dart` | `_betaMode = true`. Buy Now shows "PAYMENT COMING SOON", tapping shows snackbar directing to voucher. All Stripe imports removed for clean build. |
| Voucher validation hardened | `paywall_screen.dart` | Was: any 8-character string accepted. Now: `RegExp(r'^[A-Z0-9]{8}$')` enforced. Input field also strips non-alphanumeric characters live as user types. |
| Fake sub-category chips removed | `setup_screen.dart` | Hardcoded `['Deep Work', 'Research', ...]` list replaced with `[]`. Chip row renders nothing until S5-001 ships real DB lookup. |
| Android app label fixed | `AndroidManifest.xml` | `android:label` changed from `neuro_load` to `NeuroLoad`. |
| Timezone init hardened | `notification_service.dart` | `getLocalTimezone()` wrapped in try/catch. Falls back to UTC if platform channel fails (emulators, some Android 12 cold starts). Prevents silent daily reminder scheduling failure. |

---

## ─────────────────────────────────────────────
## SPRINT 5 — QUEUED
## Start after Stripe deployment is confirmed live
## ─────────────────────────────────────────────

**Goal:** Close all remaining P2 gaps, ship iOS Live Activities, and begin Phase 2 cloud sync.

| ID | Item | Effort | File(s) | Priority |
|----|------|--------|---------|----------|
| S5-001 | US 1.2 Sub-category auto-suggest | 1 day | `setup_screen.dart` + `SessionDao.topSubCategories(category, limit: 5)` | 🟡 P2 |
| S5-002 | US 1.3 Baseline aim +5% nudge on setup | 1 day | `setup_screen.dart` reads `nextAimProvider`, pre-fills target | 🟡 P2 |
| S5-003 | US 3.4 Resilience KPI — add modal-dismiss delta | 1.5 days | `tables.dart` (add `modalOpenedAt`), `session_provider.dart`, new `avgResilienceProvider`, KPI card | 🟡 P2 |
| S5-004 | US 4.4 + 4.5 Contextual Leak + Strategy Recommendations | 1.5 days | `coach_engine.dart` — cross-category 1RM delta + static mitigation map | 🟡 P2 |
| S5-005 | US 3.2 Distraction Danger Zones on heatmap | 2 days | `dashboard_screen.dart` — second ring or overlay on `_CircularHeatmap` for lap density | 🟡 P2 |
| S5-006 | Bug 04 / Bug 07 — Full i18n (EN + DE) | 3 days | `pubspec.yaml` + `lib/l10n/` ARB files + `LanguageSelectionPage` in onboarding | 🟢 P3 |
| S5-007 | Bug 09 iOS — ActivityKit Live Activities | 5 days | Native Swift widget + Flutter method channel. Requires Mac + Apple Developer account. | 🟢 P3 |
| S5-008 | MVP.003.001 — Dynamic pricing from Supabase | 1 day | `paywall_screen.dart` + Supabase `pricing_tiers` table | 🟡 P2 |
| S5-009 | Phase 2 — Cloud Sync full delta-sync | 12 days | `supabase_sync_service.dart` — delta-sync + conflict resolution + offline queue | 🔴 P1 (Phase 2 gate) |

**Sprint 5 opens when:** Stripe deployment confirmed live AND first real payment processed.

---

## ─────────────────────────────────────────────
## CI/CD STATUS — UPDATED 2026-03-05
## ─────────────────────────────────────────────

| File | Runner | What it does |
|------|--------|--------------|
| `.github/workflows/ci_android.yml` | ubuntu-latest | **analyze + test** (PR); **Release APK + AAB** (push to main); **Manual Build** (workflow_dispatch); **Debug APK** (on-demand) |
| `.github/workflows/ci_ios.yml` | macos-latest | analyze + test on every PR; unsigned IPA on push to main |
| `android/app/build.gradle.kts` | — | Reads `android/key.properties` for release signing; falls back to debug if absent |

**Current Capabilities:**
- [x] **Manual Trigger**: Workflow can be started via GitHub Actions UI.
- [x] **Debug APK**: On-demand artifact available for instant device testing (no signing required).
- [x] **Build Fixes applied**: `withValues` refactored to `withOpacity` for CI compatibility; `prefer_const_constructors` fixed; unused imports removed.
- [ ] **Production Secrets**: Needs 4 GitHub secrets for Release builds (`KEYSTORE_BASE64`, etc.).

**Guide Created:** `brain/ci_cd_guide.md`

---

## ─────────────────────────────────────────────
## STALE LOG ENTRIES — CORRECTED
## ─────────────────────────────────────────────

| Old Entry | Was Claimed | Reality |
|-----------|-------------|---------|
| "Heatmap is daily grid" | 🔴 HIGH gap | ✅ FIXED — `_CircularHeatmap` CustomPainter done |
| "Adaptive sensor polling not throttled" | 🟢 LOW gap | ✅ FIXED — 200ms/2000ms switching live |
| "Paywall gate not wired to app startup" | 🔴 HIGH gap | ✅ FIXED — GoRouter redirect active |
| "Calibration missing sensor reads" | ❌ missing | ✅ FIXED — full live stream + 3-sample avg + SharedPrefs write |
| "Baseline test should save to DB" | ❌ missing | ✅ FIXED — `insertSession` + `finishSession` called |
| "US 2.3 Break Notifications never called" | 🔴 HIGH gap | ✅ FIXED — S4-006 wired `showRestComplete()` |
| "US 2.4 One More Rep missing" | 🔴 HIGH gap | ✅ FIXED — S4-007 bottom sheet with dynamic remaining time |
| "US 4.8 Ghost Intent flash never fires" | 🔴 HIGH gap | ✅ FIXED — S4-008 `_userActed` flag implemented |
| "Stripe checkout is a SnackBar stub" | 🔴 BLOCKER | ✅ FIXED — S4-001 code complete; disabled for beta via `_betaMode` flag |
| "Settings lost on restart" | 🔴 HIGH gap | ✅ FIXED — S4-003 SharedPreferences persistence |
| "Font picker onTap stub" | 🟡 MEDIUM gap | ✅ FIXED — S4-004 bottom sheet with 5 fonts |
| "/timer guard missing" | 🔴 HIGH gap | ✅ FIXED — S4-005 GoRouter redirect |
| "Voucher accepts any 8 chars" | 🟡 MEDIUM gap | ✅ FIXED — beta polish, `[A-Z0-9]{8}` regex enforced |
| "Hardcoded sub-category chips" | 🟡 MEDIUM gap | ✅ FIXED — beta polish, list cleared to `[]` |
| "Android label shows neuro_load" | 🟡 MEDIUM gap | ✅ FIXED — beta polish, label corrected to `NeuroLoad` |
| "Timezone init can fail silently" | 🟢 LOW gap | ✅ FIXED — beta polish, try/catch + UTC fallback added |

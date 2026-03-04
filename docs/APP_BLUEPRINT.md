# NeuroLoad — App Blueprint

> **Last updated:** 2026-03-04  
> **Version:** 1.0  
> Single-source-of-truth for every screen, panel, tab, and navigation path in the app.

---

## Navigation Architecture

```
┌─────────────────────────────────────────┐
│              App Launch                 │
│         (main.dart + GoRouter)          │
└────────────┬───────────────┬────────────┘
             │               │
    ┌────────▼──────┐  ┌─────▼──────────────┐
    │  /onboarding  │  │    AppShell         │
    │  (first-run)  │  │  (BottomNavBar ×3)  │
    └───────────────┘  └──────┬──────────────┘
                               │
             ┌─────────────────┼─────────────────┐
             │                 │                 │
         Tab 0             Tab 1             Tab 2
       /setup           /dashboard         /settings
       🏋️ Train          📊 Progress        ⚙️ Settings
```

### Global Redirects (GoRouter)
| Condition | Redirect to |
|-----------|-------------|
| `has_completed_onboarding == false` | `/onboarding` |
| `!isPaid && freeSessionsUsed >= 1` | `/paywall` |

---

## Screens Reference

### 1. Onboarding — `/onboarding`
**File:** `lib/screens/onboarding/onboarding_screen.dart`  
**Access:** First launch only (controlled by `has_completed_onboarding` in SharedPreferences)

| Panel / Step | What it does |
|---|---|
| Welcome splash | Brand intro, app pitch |
| Sensor calibration | Reads accelerometer Z-axis baseline; stores `sensor_z_baseline` in SharedPrefs |
| Face-down demo | User places phone face-down to verify sensor works |
| Complete | Sets `has_completed_onboarding = true` → redirects to `/setup` |

---

### 2. Setup — `/setup` (Tab 0: Train)
**File:** `lib/screens/setup/setup_screen.dart`  
**Shell tab:** 🏋️ Train  

| Panel | What it does |
|---|---|
| Category selector | `ChoiceChip` row: Study / Work / Creative / Admin / Lifestyle |
| Duration picker | Target session duration (minutes) |
| Face-down toggle | Enable/disable phone-face-down lap trigger |
| **START** button | Validates inputs → navigates to `/timer` |

---

### 3. Timer — `/timer`
**File:** `lib/screens/timer/timer_screen.dart`  
**Access:** Navigated to from `/setup` via START button  
**Background:** Android Foreground Service keeps timer alive when app is minimised

| Panel | What it does |
|---|---|
| Elapsed clock | Live HH:MM:SS driven by `sessionProvider` tick |
| Quality score bar | Real-time score based on lap frequency & distraction count |
| Focus density chip | `focusDensity` %  |
| Live recording badge | `● REC` indicator showing active session |
| Lap button | Tap → records distraction lap (`DistractionTrigger` + optional note modal) |
| Face-down auto-lap | Accelerometer detects face-down → auto-triggers lap with `FaceDown` trigger type |
| **FINISH** button | Ends session → increments `freeSessionsUsedProvider` → navigates to `/summary` |

---

### 4. Summary — `/summary`
**File:** `lib/screens/summary/summary_screen.dart`  
**Access:** After FINISH on Timer

| Panel | What it does |
|---|---|
| Session header | Duration, category, date |
| Quality score card | Final score with grade indicator |
| 1RM display | Session one-rep-max in seconds |
| Lap feed | Chronological list of all laps with trigger icons |
| Coach insights | AI-generated insights from `CoachEngine` (de-load warning, PB alert, next aim) |
| **Break timer** button | Navigates to `/break` with earned break duration |
| **Done** button | Returns to `/setup` |

---

### 5. Break Timer — `/break`
**File:** `lib/screens/summary/break_timer_screen.dart`  
**Access:** From Summary screen (passed `earned Duration` as GoRouter extra)

| Panel | What it does |
|---|---|
| Countdown ring | Visual countdown of earned break time |
| Rest mode | Full-screen minimal UI, no nav bar |
| Complete handler | Auto-returns to `/setup` when break ends |

---

### 6. Dashboard — `/dashboard` (Tab 1: Progress)
**File:** `lib/screens/dashboard/dashboard_screen.dart`  
**Shell tab:** 📊 Progress

| Panel / Widget | Provider | What it shows |
|---|---|---|
| Category filter bar | `categoryFilterProvider` | All / Study / Work / Creative / Admin / Lifestyle chips — filters all cards below |
| **24-hr Circular Focus Ring** | `completedSessionsProvider` | 24-segment clock ring; arc width + opacity = total focus minutes per hour; tap to toggle to 90-day grid fallback |
| Total sessions KPI | `completedSessionsProvider` | Count of completed sessions |
| Total focus time KPI | `completedSessionsProvider` | Sum of `totalElapsedSeconds` formatted as hours |
| Average quality score KPI | `completedSessionsProvider` | Mean quality score across sessions |
| Focus density KPI | `avgFocusDensityProvider` | Average focus density % |
| All-time 1RM KPI | `allTimeOneRmProvider` | Best ever one-rep-max in seconds |
| **1RM Line Chart** | `allTimeOneRmProvider` | `fl_chart` line chart of 1RM per session |
| **Distraction Donut** | `triggerCountMapProvider` | Pie chart of distraction triggers by category |
| Trophy Room shortcut | — | Taps → `/trophies` |

---

### 7. Settings — `/settings` (Tab 2: Settings)
**File:** `lib/screens/settings/settings_screen.dart`  
**Shell tab:** ⚙️ Settings

| Section | Setting | Behaviour |
|---|---|---|
| **LICENCE** | Status chip | Live `isPaidProvider` watch — shows `PLUS ✓` (teal) or `FREE` (amber) |
| **LICENCE** | Upgrade to NeuroLoad Pro | Navigates to `/paywall` (hidden when paid) |
| **PRIVACY & DATA** | Face-down sensitivity | Slider adjusts Z-axis threshold stored in SharedPrefs |
| **PRIVACY & DATA** | Strict privacy mode | Toggle — when on, notes are nulled before Cloud Sync upload |
| **PRIVACY & DATA** | Export Data (CSV) | Generates `sessions.csv` + `laps.csv` via `share_plus` |
| **PRIVACY & DATA** | Delete Account | Wipes Drift DB + SharedPrefs + resets all providers in-memory |
| **CLOUD SYNC** | Supabase URL + Anon Key | Bottom sheet entry, `testConnection()` ping on save |
| **CLOUD SYNC** | Sync now | Calls `SupabaseSyncService.syncAll()`, shows status chip (↺ / ✓ / ✗) |
| **CLOUD SYNC** | Cloud sync toggle | Stored in `settingsProvider` |

---

### 8. Paywall — `/paywall`
**File:** `lib/screens/paywall/paywall_screen.dart`  
**Access:** Triggered automatically by GoRouter gate after 1 free session, or tapped from Settings

| Panel | What it does |
|---|---|
| Hero copy | "Your free session is complete." |
| Scarcity badge | "TIER 1 — 300 REMAINING" |
| Price card | €49 one-time, feature list (Unlimited sessions, Cloud sync, Coach intelligence, 24-hr Focus Ring) |
| **UNLOCK** CTA | [Stripe stub] — shows SnackBar while Stripe checkout is pending |
| Voucher code | 8-char uppercase code → calls `markPaid()` (800ms simulated RPC) → auto-navigates home |
| EU refund notice | "14-day refund policy applies" |

---

### 9. Trophy Room — `/trophies`
**File:** `lib/screens/trophy_room/trophy_room_screen.dart`  
**Access:** Via Dashboard card shortcut

| Panel | What it shows |
|---|---|
| Top 5 sessions by 1RM | Session date, category, 1RM seconds, quality score |
| Personal records grid | All-time bests across each category |

---

## State Providers

```
lib/providers/
├── session_provider.dart       # SessionNotifier (active session state: timer, laps, quality, 1RM)
│                               # settingsProvider (face-down toggle, category)
│                               # AppSettings model
├── sensor_provider.dart        # FaceDownNotifier (accelerometer → face-down bool)
│                               # zombieSessionProvider (orphaned session detection)
├── coach_provider.dart         # CoachEngine (insights, nextAim, de-load, PB detection)
│                               # nextAimProvider, coachInsightsProvider
└── subscription_provider.dart  # isPaidProvider (SharedPrefs bool)
                                # freeSessionsUsedProvider (counter)
                                # paywallGateProvider (derived gate: !paid && used >= 1)
```

---

## Data Layer

```
lib/data/
├── app_database.dart           # Drift database — SessionsTable, LapsTable
├── tables.dart                 # Table definitions
├── session_dao.dart            # CRUD + analytics queries for sessions
├── lap_dao.dart                # CRUD for laps
└── database_providers.dart     # Riverpod providers wrapping DAOs
```

---

## Services

```
lib/services/
├── foreground_service.dart     # Android FGS wrapper (flutter_foreground_task)
├── foreground_task_handler.dart # Isolate tick handler → sends 'tick' to main
├── notification_service.dart   # Local notification for active session badge
├── supabase_sync_service.dart  # Cloud sync (sessions + laps → Supabase REST)
└── export_service.dart         # CSV export via share_plus
```

---

## End-to-End Session Flow

```
SetupScreen
  │ START pressed
  ▼
TimerScreen
  │ (FGS active, 1-second tick, face-down auto-lap)
  │ FINISH pressed
  ▼
  session saved to Drift DB
  freeSessionsUsed incremented
  │
  ├─ isPaid == false && used >= 1 ?
  │     └─ GoRouter redirects to /paywall on next navigation
  │
  └─ navigate to /summary
       │ Done button
       ▼
      /setup
```

---

## Design System

**Theme file:** `lib/theme/app_theme.dart`

| Token | Value |
|---|---|
| Background | `#0A0A0F` (near-black) |
| Surface | `#12121A` |
| Surface Elevated | `#1A1A26` |
| Accent (Teal) | `#00E5C8` |
| Warning | `#FFB347` |
| Error | `#FF4D6D` |
| Text Primary | `#FFFFFF` |
| Text Secondary | `#8B8B9E` |
| Text Tertiary | `#4A4A5E` |
| Font | `Inter` (Google Fonts) |

# NeuroLoad — Technical Architecture

> **Last updated:** 2026-03-04

---

## Layer Overview

```
┌──────────────────────────────────────────────────────────┐
│                        UI Layer                          │
│         lib/screens/**  +  lib/theme/app_theme.dart      │
│   ConsumerWidget / ConsumerStatefulWidget (Riverpod)     │
└────────────────────────┬─────────────────────────────────┘
                          │ ref.watch / ref.read
┌────────────────────────▼─────────────────────────────────┐
│                    Provider Layer                         │
│             lib/providers/  (Riverpod)                   │
│  sessionProvider · faceDownStartProvider                  │
│  coachInsightsProvider · isPaidProvider                   │
└────────────────────────┬─────────────────────────────────┘
                          │ read DAOs / services
┌────────────────────────▼─────────────────────────────────┐
│                  Service / Data Layer                     │
│   lib/data/       → Drift SQLite (sessions + laps)       │
│   lib/services/   → FGS · notifications · sync · export  │
└──────────────────────────────────────────────────────────┘
```

---

## State Management

All state is managed with **Riverpod** (`flutter_riverpod`).

### Core Providers

```
providers/session_provider.dart
│
├── SessionNotifier (StateNotifier<SessionState>)
│     State: phase, elapsed, laps, quality score, 1RM, category, dbSessionId
│     Actions: startSession, tick, recordLap, finishSession, resetSession,
│              resumeZombieSession, updateSettings
│
└── settingsProvider (StateNotifierProvider<SettingsNotifier, AppSettings>)
      Persists: faceDownEnabled, category preference

providers/sensor_provider.dart
│
├── FaceDownNotifier (StateNotifier<bool>)
│     Streams accelerometerEventStream (normalInterval → US 7.3: adaptive)
│     Loads z-baseline from SharedPrefs on startup
│     Emits true after 1500ms hold below threshold
│     Action: consume() — resets to false after event is handled
│
└── zombieSessionProvider (FutureProvider<ZombieSession?>)
      Reads sessionDao.findIncomplete() on app launch

providers/coach_provider.dart
│
└── CoachEngine + coachInsightsProvider (StreamProvider)
      Analyses last N sessions → produces:
      · nextAimSuggestion (target 1RM for next session)
      · deloadWarning (quality drop > 15pts over 3 sessions)
      · PB alert (current 1RM == all-time 1RM)
      · distractionInsight (top trigger category %)
      Baseline gate: silenced until 10 sessions recorded

providers/subscription_provider.dart
│
├── SubscriptionNotifier (StateNotifier<bool>)  → isPaidProvider
│     Persists: SharedPrefs 'subscription_is_paid'
│     Actions: markPaid(), revoke()
│
├── FreeSessionsNotifier (StateNotifier<int>)  → freeSessionsUsedProvider
│     Persists: SharedPrefs 'subscription_free_sessions_used'
│     Actions: increment(), reset()
│
└── paywallGateProvider (Provider<bool>)
      Derived: !isPaid && used >= kFreeSessionLimit (1)
```

---

## Routing

**Package:** `go_router`  
**File:** `lib/router.dart`

```
Router
 ├── Global redirect (async): onboarding check → paywall gate check
 ├── /onboarding         → OnboardingScreen
 ├── /paywall            → PaywallScreen  (outside ShellRoute)
 ├── /break              → BreakTimerScreen  (outside ShellRoute)
 └── ShellRoute → AppShell (BottomNavigationBar ×3)
       ├── /setup         → SetupScreen        (Tab 0: Train)
       ├── /timer         → TimerScreen        (nested under Train)
       ├── /summary       → SummaryScreen      (nested under Train)
       ├── /dashboard     → DashboardScreen    (Tab 1: Progress)
       ├── /settings      → SettingsScreen     (Tab 2: Settings)
       └── /trophies      → TrophyRoomScreen   (nested, dashboard → trophies)
```

### Redirect Logic

```dart
// 1. Onboarding gate
if (!hasOnboarded && path != '/onboarding') return '/onboarding';

// 2. Paywall gate (shell paths only, not onboarding)
final gateHit = !isPaid && freeSessionsUsed >= 1;
if (gateHit && isShellPath && path != '/paywall') return '/paywall';
```

---

## Database

**Package:** `drift` (SQLite ORM)  
**File:** `lib/data/app_database.dart`

### Tables

#### `sessions`
| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK | Auto-increment |
| `started_at` | INTEGER | Unix ms |
| `ended_at` | INTEGER? | Null if incomplete |
| `category` | TEXT | e.g. 'Study' |
| `quality_score` | REAL | 0–100 |
| `focus_density` | REAL | % |
| `one_rm_seconds` | INTEGER | Best lap duration (seconds) |
| `total_elapsed_seconds` | INTEGER | Session duration |
| `lap_count` | INTEGER | |

#### `laps`
| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK | Auto-increment |
| `session_id` | INTEGER FK | → sessions.id |
| `occurred_at` | INTEGER | Unix ms |
| `trigger` | TEXT | DistractionTrigger enum name |
| `note` | TEXT? | Optional user note |
| `lap_duration_seconds` | INTEGER | Seconds since last lap |

### DAOs

- **SessionDao** — insert, update(finish), findIncomplete, abandon, analytics queries
- **LapDao** — insertMany, listForSession

---

## Android Foreground Service

**Package:** `flutter_foreground_task`  
**Purpose:** Keep the 1-second timer running when the user minimises the app

```
ForegroundTaskHandler (isolate)
  └── onRepeatEvent() every 1 second
        └── FlutterForegroundTask.sendDataToMain('tick')

main.dart → addTaskDataCallbackWithToken()
  └── sessionProvider.notifier.tick()
```

The notification text ("NeuroLoad session active") is displayed in the Android notification shade.

---

## Sensor System

**Package:** `sensors_plus`  
**Provider:** `FaceDownNotifier`

```
accelerometerEventStream(samplingPeriod: normalInterval)
  └── _onEvent(AccelerometerEvent e)
        if (e.z <= _zThreshold) for 1500ms
          → emit true  (face-down confirmed)

US 7.3 (TODO): throttle to 2000ms polling when session is idle/background
                speed up to 200ms when session is active
```

---

## Cloud Sync

**Service:** `lib/services/supabase_sync_service.dart`  
**Trigger:** Manual "Sync now" button in Settings  
**Auth:** Supabase anon key (entered by user)

```
syncAll(localOnlyNotes: bool)
  ├── upsert sessions → supabase_project/rest/v1/sessions
  └── upsert laps     → supabase_project/rest/v1/laps
      (if localOnlyNotes: note field is nulled before upload)
```

---

## Design System

**File:** `lib/theme/app_theme.dart`

- **Dark-only** theme
- Font: **Inter** (Google Fonts)
- Colors: near-black background (`#0A0A0F`), teal accent (`#00E5C8`)
- All colors referenced as `AppColors.*` constants — never hardcoded in widgets

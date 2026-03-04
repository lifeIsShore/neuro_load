# NeuroLoad

> **Cognitive performance training app for Android.**  
> Track focus sessions, quantify distraction, and improve over time.

---

## What it does

NeuroLoad gamifies cognitive work sessions the same way strength coaches track barbell lifts. You set a timer, place your phone face-down to signal focus, tap when you get distracted, and at the end receive a **quality score** and a **1RM** (one-rep-max in seconds) — your personal benchmark that you try to beat each session.

---

## Quick Start

### Prerequisites
- Flutter `>=3.24.0`
- Dart `>=3.4.0`
- Android SDK 21+ (iOS builds supported but FGS not tested)
- Java 17 (for Android Gradle builds)

### Install & Run

```bash
cd neuro_load
flutter pub get
flutter run
```

### Run on physical device (recommended — sensor features)
```bash
flutter run -d <device-id>
```

### Build release APK
```bash
flutter build apk --release
```

---

## Project Structure

```
neuro_load/
├── lib/
│   ├── main.dart                  # Entry point — ProviderScope + MaterialApp
│   ├── router.dart                # GoRouter — routes + global redirect guards
│   ├── data/                      # Drift DB — tables, DAOs, migrations
│   ├── providers/                 # Riverpod state (session, sensor, coach, subscription)
│   ├── screens/                   # One folder per screen
│   │   ├── onboarding/
│   │   ├── setup/
│   │   ├── timer/
│   │   ├── summary/
│   │   ├── dashboard/
│   │   ├── settings/
│   │   ├── paywall/
│   │   ├── trophy_room/
│   │   └── shell/                 # AppShell (BottomNavBar wrapper)
│   ├── services/                  # FGS, notifications, cloud sync, CSV export
│   └── theme/                     # AppColors + AppTheme (dark, Inter font)
├── android/                       # Native Android config (FGS manifest entries)
├── planning/
│   └── IMPLEMENTATION_LOG.md      # Story-level TODO tracker
└── docs/                          # ← You are here
    ├── README.md
    ├── APP_BLUEPRINT.md           # All screens, tabs, navigation paths
    └── ARCHITECTURE.md            # Technical layers and data flow
```

---

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Declarative routing + redirect guards |
| `drift` | Local SQLite ORM |
| `flutter_foreground_task` | Android Foreground Service (keeps timer alive) |
| `sensors_plus` | Accelerometer — face-down detection |
| `fl_chart` | Analytics charts (1RM line, distraction donut) |
| `local_notifications` | Persistent session notification |
| `shared_preferences` | Light key-value store (onboarding, subscription, config) |
| `share_plus` | CSV export via OS share sheet |
| `google_fonts` | Inter typeface |

---

## Monetisation

- **Free tier:** 1 session
- **NeuroLoad Plus:** €49 lifetime, unlocked via:
  - Stripe Checkout (TODO — stub in place)
  - Voucher code (any 8-char code accepted in dev build)
- Gate implemented via `subscription_provider.dart` + GoRouter global redirect

---

## Cloud Sync (Optional, Paid)

Users can opt in to Supabase sync from Settings. Requires entering a Supabase Project URL + Anon Key. Sessions and laps (optionally stripped of notes via Strict Privacy Mode) are upserted to a Supabase Postgres instance.

---

## Docs

- [`APP_BLUEPRINT.md`](./APP_BLUEPRINT.md) — All screens, panels, navigation
- [`ARCHITECTURE.md`](./ARCHITECTURE.md) — Technical layers, providers, data flow
- [`../planning/IMPLEMENTATION_LOG.md`](../planning/IMPLEMENTATION_LOG.md) — Story tracking

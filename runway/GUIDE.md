# NeuroLoad — CI/CD & Implementation Guide
**Folder:** `runway/`  
**Purpose:** Single source of truth for CI/CD setup, future implementation tasks, and developer onboarding.  
**Repo:** https://github.com/lifeIsShore/neuro_load  
**Last Updated:** 2026-03-05

---

## Table of Contents

1. [Folder Purpose](#1-folder-purpose)
2. [Repository Branch Strategy](#2-repository-branch-strategy)
3. [GitHub Actions — Pipeline Overview](#3-github-actions--pipeline-overview)
4. [Android CI/CD — Step-by-Step Setup](#4-android-cicd--step-by-step-setup)
5. [iOS CI/CD — Step-by-Step Setup](#5-ios-cicd--step-by-step-setup)
6. [Local Development Setup](#6-local-development-setup)
7. [Code Generation (Drift + Riverpod)](#7-code-generation-drift--riverpod)
8. [Environment Variables & Secrets Reference](#8-environment-variables--secrets-reference)
9. [Implementation Backlog](#9-implementation-backlog)
10. [Definition of Done](#10-definition-of-done)

---

## 1. Folder Purpose

The `runway/` folder is the **operational home** of this project. It contains:

```
runway/
├── GUIDE.md                  ← This file. Read first.
├── IMPLEMENTATION_BACKLOG.md ← Prioritised work queue (replace planning/IMPLEMENTATION_LOG.md over time)
└── SECRETS_CHECKLIST.md      ← One-time setup checklist for new environments
```

All planning docs in `planning/` remain as product/business references.  
`runway/` is strictly for engineering execution.

---

## 2. Repository Branch Strategy

```
main          ← Protected. CI runs on every push. Artifacts built here.
              ← Direct pushes blocked — use PRs.

feature/*     ← All new work. PR into main when ready.
              ← CI (analyze + test) runs automatically on PR open.

bugfix/*      ← Bug fixes. Same flow as feature branches.

release/*     ← (Future) Release candidates. AAB uploaded to Play Store internal track.
```

### Rules
- Never push secrets, keystores, or `.env` files to any branch.
- PR must pass all CI checks before merge — no overrides.
- Bump `version` in `pubspec.yaml` before tagging a release (`git tag v1.0.0`).

---

## 3. GitHub Actions — Pipeline Overview

Two workflow files live in `.github/workflows/`:

| File | Runner | Triggers | Jobs |
|------|--------|----------|------|
| `ci_android.yml` | `ubuntu-latest` | push to `main`, PR to `main` | analyze+test → build APK → build AAB |
| `ci_ios.yml` | `macos-latest` | push to `main`, PR to `main` | analyze+test → build unsigned IPA |

### Flow Diagram

```
Push / PR to main
       │
       ├─► [ubuntu] ci_android.yml
       │         │
       │         ├─ Job 1: flutter analyze + flutter test
       │         ├─ Job 2: flutter build apk --release   (main only)
       │         └─ Job 3: flutter build appbundle       (main only)
       │
       └─► [macos]  ci_ios.yml
                 │
                 ├─ Job 1: flutter analyze + flutter test
                 └─ Job 2: flutter build ios --no-codesign (main only)
```

Build artifacts (APK, AAB, unsigned IPA) are uploaded as GitHub Actions Artifacts.  
Retention: **14 days** for builds, **7 days** for coverage reports.

---

## 4. Android CI/CD — Step-by-Step Setup

### 4.1 Create a Release Keystore (one-time, local)

Run this once on your local machine. Keep the output file **permanently safe** — losing it means you can never update the app on the Play Store.

```bash
keytool -genkey -v \
  -keystore neuroload-release.jks \
  -alias neuroload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

You'll be prompted for:
- `storePassword` — the keystore password (save this)
- `keyPassword` — the key password (save this, can be same as store)
- `keyAlias` — use `neuroload`
- Distinguished name fields (name, org, city, country)

Store the resulting `.jks` file in a password manager or encrypted backup. **Never commit it.**

### 4.2 Base64-encode the Keystore

```bash
# macOS / Linux
base64 -i neuroload-release.jks | pbcopy   # copies to clipboard

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("neuroload-release.jks")) | Set-Clipboard
```

### 4.3 Add GitHub Secrets

Go to: **GitHub → neuro_load repo → Settings → Secrets and variables → Actions → New repository secret**

Add these four secrets exactly as named:

| Secret Name | Value |
|-------------|-------|
| `KEYSTORE_BASE64` | The base64 string from step 4.2 |
| `KEY_ALIAS` | `neuroload` (or whatever alias you chose) |
| `KEY_PASSWORD` | The key password from step 4.1 |
| `STORE_PASSWORD` | The store password from step 4.1 |

### 4.4 How the CI Uses Them

The workflow `ci_android.yml` does this automatically:

```yaml
- name: Decode keystore
  run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/release.jks

- name: Write key.properties
  run: |
    cat > android/key.properties <<EOF
    storePassword=${{ secrets.STORE_PASSWORD }}
    keyPassword=${{ secrets.KEY_PASSWORD }}
    keyAlias=${{ secrets.KEY_ALIAS }}
    storeFile=release.jks
    EOF
```

`android/app/build.gradle.kts` reads `key.properties` and applies the signing config.  
If `key.properties` is absent (local dev without secrets), it falls back to debug signing.

### 4.5 Local Development Signing

For local release builds, create `android/key.properties` manually:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=neuroload
storeFile=release.jks
```

And copy your `neuroload-release.jks` into `android/app/release.jks`.

Both files are in `.gitignore` — they will never be committed.

### 4.6 Downloading Build Artifacts

After a push to `main`:
1. Go to **GitHub → neuro_load → Actions → latest Android CI run**
2. Scroll to **Artifacts**
3. Download `neuroload-release-apk` or `neuroload-release-aab`

---

## 5. iOS CI/CD — Step-by-Step Setup

### 5.1 Current State (Unsigned Builds)

The `ci_ios.yml` workflow currently produces an **unsigned IPA** that cannot be installed on physical devices or submitted to the App Store. This is intentional — we're validating that the build compiles cleanly without paying for Apple certificates in CI yet.

### 5.2 What You Need for Signed Builds (when ready)

1. **Apple Developer Account** (Individual or Organisation, $99/year)
2. **Distribution Certificate (.p12)** — created in Xcode → Preferences → Accounts, or Keychain Access
3. **App Store Provisioning Profile (.mobileprovision)** — created in developer.apple.com for App ID `com.neuroload.neuro_load`
4. **App Store Connect API Key (.p8)** — created in App Store Connect → Users → Keys

### 5.3 Register the App ID

1. Go to developer.apple.com → Certificates, Identifiers & Profiles
2. Create an App ID: `com.neuroload.neuro_load`
3. Enable capabilities: Push Notifications (if needed later), Sign in with Apple (not needed now)

### 5.4 Add iOS Secrets to GitHub

When ready for TestFlight, add these secrets:

| Secret Name | Value |
|-------------|-------|
| `APPLE_CERTIFICATE_BASE64` | Base64-encoded `.p12` distribution certificate |
| `APPLE_CERTIFICATE_PASSWORD` | `.p12` password |
| `APPLE_PROVISION_PROFILE_BASE64` | Base64-encoded `.mobileprovision` |
| `APPLE_TEAM_ID` | 10-character team ID from developer.apple.com |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from App Store Connect |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID from App Store Connect |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64-encoded `.p8` private key |

### 5.5 Enabling Signed Builds + TestFlight

In `.github/workflows/ci_ios.yml`, uncomment the `deploy_testflight` job block at the bottom of the file. The commented block already contains all required steps — just fill in the secrets above.

### 5.6 Xcode Version Note

The workflow uses `macos-latest` which ships with a recent Xcode. If your project requires a specific Xcode version (e.g. after an iOS SDK update), add:

```yaml
- uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: '16.0'
```

before the Flutter setup step.

---

## 6. Local Development Setup

### 6.1 Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter SDK | 3.24.0 | https://docs.flutter.dev/get-started/install |
| Dart SDK | bundled with Flutter | — |
| Java JDK | 17 (Temurin) | https://adoptium.net |
| Android Studio | Latest | For emulator + SDK |
| Xcode | Latest (Mac only) | Mac App Store |
| CocoaPods | Latest (Mac only) | `sudo gem install cocoapods` |

### 6.2 Clone & Run

```bash
git clone https://github.com/lifeIsShore/neuro_load.git
cd neuro_load

# Install Flutter dependencies
flutter pub get

# Run code generation (MUST do this before first run)
dart run build_runner build --delete-conflicting-outputs

# Run on connected device or emulator
flutter run
```

### 6.3 Common Commands

```bash
# Analyze code
flutter analyze

# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Build debug APK
flutter build apk --debug

# Build release APK (requires local key.properties)
flutter build apk --release

# Build release AAB for Play Store
flutter build appbundle --release

# Build iOS (no signing)
flutter build ios --release --no-codesign

# Clean build artifacts
flutter clean && flutter pub get
```

---

## 7. Code Generation (Drift + Riverpod)

This project uses two code generators that MUST be re-run after changing:
- Any `@DriftDatabase`, `@DriftAccessor`, or `@DataClassName` annotated file
- Any `@riverpod` annotated provider

```bash
# One-shot generation (recommended)
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development (auto-regenerates on file save)
dart run build_runner watch --delete-conflicting-outputs
```

Generated files (committed to repo, do not edit manually):
```
lib/data/app_database.g.dart
lib/data/daos/session_dao.g.dart
lib/data/daos/lap_dao.g.dart
```

If you see `Could not find a file for part` errors — you forgot to run build_runner.

---

## 8. Environment Variables & Secrets Reference

### 8.1 GitHub Actions Secrets (complete list)

| Secret | Used By | Required Now? |
|--------|---------|---------------|
| `KEYSTORE_BASE64` | `ci_android.yml` | ✅ Yes — for signed Android builds |
| `KEY_ALIAS` | `ci_android.yml` | ✅ Yes |
| `KEY_PASSWORD` | `ci_android.yml` | ✅ Yes |
| `STORE_PASSWORD` | `ci_android.yml` | ✅ Yes |
| `APPLE_CERTIFICATE_BASE64` | `ci_ios.yml` | ⏳ When App Store ready |
| `APPLE_CERTIFICATE_PASSWORD` | `ci_ios.yml` | ⏳ When App Store ready |
| `APPLE_PROVISION_PROFILE_BASE64` | `ci_ios.yml` | ⏳ When App Store ready |
| `APPLE_TEAM_ID` | `ci_ios.yml` | ⏳ When App Store ready |
| `APP_STORE_CONNECT_API_KEY_ID` | `ci_ios.yml` | ⏳ When App Store ready |
| `APP_STORE_CONNECT_API_ISSUER_ID` | `ci_ios.yml` | ⏳ When App Store ready |
| `APP_STORE_CONNECT_API_KEY_BASE64` | `ci_ios.yml` | ⏳ When App Store ready |

### 8.2 Runtime App Secrets (Supabase — entered by user in Settings)

These are NOT stored in the codebase or CI. The user enters them in **Settings → Supabase Credentials**:
- Supabase Project URL
- Supabase Anon Key

Stored in `SharedPreferences` under keys `supabase_project_url` and `supabase_anon_key`.

### 8.3 Future: Stripe Keys (MVP.003.003)

When Stripe is integrated, add to GitHub Secrets:
- `STRIPE_PUBLISHABLE_KEY` — safe to include in app bundle
- `STRIPE_SECRET_KEY` — **NEVER in app bundle**, only in Supabase Edge Functions

---

## 9. Implementation Backlog

Full detail in `planning/IMPLEMENTATION_LOG.md` Sprint 4 + Sprint 5 sections. Summary here.

### 🔴 Sprint 4 — Beta blockers (do these first)

| ID | Task | Effort | Status |
|----|------|--------|--------|
| S4-001 | Stripe Checkout end-to-end (Edge Functions + paywall wire-up) | 8–10 days | ❌ Not started |
| S4-002 | Bug 08: Calibration live test phase (flip-to-confirm) | 1 day | 🔨 Partial |
| S4-003 | Persist `settingsProvider` to SharedPreferences | 1 day | ❌ Not started |
| S4-004 | Font picker UI in Settings | 0.5 days | ❌ Not started |
| S4-005 | `/timer` + `/summary` route guards | 0.5 days | ❌ Not started |
| S4-006 | Break notifications T-60s + T-0 (US 2.3) | 1 day | ❌ Not started |
| S4-007 | "One More Rep" nudge on finish (US 2.4) | 0.5 days | ❌ Not started |
| S4-008 | Ghost Intent flash before modal dismiss (US 4.8) | 0.5 days | ❌ Not started |

### 🟢 Sprint 5 — Post-beta polish

| ID | Task | Effort |
|----|------|--------|
| S5-001 | Sub-category auto-suggest from DB history (US 1.2) | 1 day |
| S5-002 | Baseline aim +5% nudge display on setup screen (US 1.3) | 1 day |
| S5-003 | Resilience KPI tracking + card (US 3.4) | 1 day |
| S5-004 | Contextual Leak + Strategy Recommendations in CoachEngine (US 4.4/4.5) | 1 day |
| S5-005 | Distraction Danger Zones on heatmap (US 3.2) | 2 days |
| S5-006 | Full i18n system (Bug 04 / Bug 07 locale URLs) | 3 days |
| S5-007 | iOS ActivityKit Live Activities (Bug 09 iOS) | 5 days |

---

## 10. Definition of Done

A feature or bug fix is considered **Done** when ALL of the following are true:

- [ ] Code is committed on a `feature/*` or `bugfix/*` branch
- [ ] `flutter analyze` passes with zero errors and zero warnings
- [ ] `flutter test` passes — new logic has at least one unit test
- [ ] `dart run build_runner build` produces no conflicts
- [ ] PR is opened targeting `main`
- [ ] GitHub Actions CI (both Android and iOS jobs) go green on the PR
- [ ] `planning/IMPLEMENTATION_LOG.md` **and** `runway/GUIDE.md` backlog table are updated
- [ ] PR is reviewed (self-review is acceptable for solo dev) and merged

---

*This document is the ground truth for all engineering operations on the NeuroLoad project.*  
*Update it as the project evolves. Do not let it go stale.*

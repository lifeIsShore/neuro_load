# NeuroLoad — Secrets & Environment Setup Checklist
**Use this when:** setting up a new machine, onboarding a new dev, or recovering from a lost environment.

---

## Android Release Signing

- [ ] Generate `neuroload-release.jks` keystore (see GUIDE.md §4.1)
- [ ] Back up `.jks` file to password manager / encrypted storage
- [ ] Base64-encode the `.jks` and store as GitHub Secret `KEYSTORE_BASE64`
- [ ] Add `KEY_ALIAS`, `KEY_PASSWORD`, `STORE_PASSWORD` to GitHub Secrets
- [ ] Copy `.jks` to `android/app/release.jks` for local builds
- [ ] Create `android/key.properties` locally (see GUIDE.md §4.5)
- [ ] Confirm `android/key.properties` and `android/app/release.jks` appear in `.gitignore`

## iOS Distribution (when ready)

- [ ] Apple Developer account active ($99/year)
- [ ] App ID `com.neuroload.neuro_load` registered at developer.apple.com
- [ ] Distribution certificate exported as `.p12` + backed up
- [ ] App Store provisioning profile downloaded
- [ ] App Store Connect API key (`.p8`) downloaded
- [ ] All 7 iOS secrets added to GitHub (see GUIDE.md §5.4)
- [ ] `deploy_testflight` job in `ci_ios.yml` uncommented

## Supabase (Runtime — entered by user, not CI)

- [ ] Supabase project created at supabase.com
- [ ] `sessions` and `laps` tables created (schema mirrors Drift tables in `lib/data/tables.dart`)
- [ ] RLS policies set: authenticated users can only read/write their own rows
- [ ] Anon key noted for user entry in app Settings

## Stripe (MVP.003.003 — not yet started)

- [ ] Stripe account created, test mode enabled
- [ ] Product created: "NeuroLoad Lifetime", price €49.00 one-time
- [ ] `STRIPE_PUBLISHABLE_KEY` stored in GitHub Secrets
- [ ] `STRIPE_SECRET_KEY` stored as Supabase Edge Function secret (NOT in GitHub / app)
- [ ] Webhook endpoint registered in Stripe Dashboard pointing to Supabase Edge Function URL
- [ ] Webhook signing secret stored as Supabase secret

## Local Machine

- [ ] Flutter 3.24.0 installed (`flutter --version`)
- [ ] Java 17 (Temurin) installed (`java -version`)
- [ ] Android Studio + SDK installed
- [ ] `flutter doctor` shows no errors
- [ ] `flutter pub get` succeeds
- [ ] `dart run build_runner build --delete-conflicting-outputs` succeeds
- [ ] `flutter test` passes
- [ ] App runs on Android emulator or physical device

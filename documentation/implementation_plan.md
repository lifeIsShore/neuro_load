# Plan to Fix APK Build Error

The current build failure is caused by a Kotlin compiler crash during the `assembleRelease` task. This crash is triggered by an incompatibility between the project's Kotlin version (`1.9.24`) and the Jetpack Glance library version (`1.1.0-rc01`).

Glance `1.1.0` and its release candidates were compiled with Kotlin 2.0 (K2). The Kotlin 1.9 compiler used by the current Flutter environment cannot correctly inline functions from libraries compiled with K2, leading to the `FunctionCodegen` error seen in the logs.

## Proposed Changes

### Android Build Configuration
Downgrade Glance dependencies to the last stable version compatible with Kotlin 1.x.

#### [MODIFY] [build.gradle.kts](file:///c:/Users/ahmty/Desktop/flowstate-example/neuro_load/android/app/build.gradle.kts)
- Update root `build.gradle.kts` to strictly pin `androidx.glance` and `androidx.datastore` to `1.0.0` to avoid K2 (Kotlin 2.x) library components.

#### [MODIFY] [NeuroLoadWidget.kt](file:///c:/Users/ahmty/Desktop/flowstate-example/neuro_load/android/app/src/main/kotlin/com/neuroload/neuro_load/NeuroLoadWidget.kt)
- **Compilation Regression Fixes**: Addressed errors in `NeuroLoadWidget.kt` introduced by the manual workaround and Glance downgrade:
    - **Glance 1.0.0 API Adjustments:**
    - `GlanceModifier.background()` requires two colors: `background(day, night)`. passing a single color results in a compiler error.
    - `ColorProvider` for `TextStyle` takes a single color in 1.0.0: `ColorProvider(color)`. Multiple arguments or positional day/night arguments are not supported in this version.
    - Suspension fixes (fetching state outside of `provideContent`) remain in place.
- **Windows Developer Mode**: User has enabled Developer Mode to resolve symlink issues.

## Known Windows Build Issue: Developer Mode

The build on Windows may fail with a "symlink" error if **Developer Mode** is not enabled. 

> [!IMPORTANT]
> To fix the symlink error, please enable **Developer Mode** in your Windows Settings:
> 1. Open **Settings** -> **Privacy & security** -> **For developers**.
> 2. Toggle **Developer Mode** to **On**.

## Verification Plan

### Automated Tests
- Run `./gradlew assembleRelease` in the `android` directory to verify that the APK builds successfully.
- Run `flutter build apk --release` from the project root.

### Manual Verification
- Install the generated APK on a device or emulator.
- Add the "NeuroLoad" widget to the home screen and verify it renders correctly (Idle and Active states).

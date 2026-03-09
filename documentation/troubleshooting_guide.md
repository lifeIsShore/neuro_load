# Android Build Troubleshooting & Maintenance Guide

This document summarizes the issues encountered during the `neuro_load` APK build and provides a reference for solving similar problems in the future.

## 1. The Core Problem: Kotlin Version Mismatch

### What happened?
The build failed with a **Kotlin Compiler Crash** (`FunctionCodegen` error). 
- **Cause**: The project uses **Kotlin 1.9.24**. However, the `androidx.glance` library (version `1.1.0-rc01`) was compiled with **Kotlin 2.0 (K2)**.
- **Result**: Kotlin 1.9 cannot safely inline functions or handle metadata from libraries built with Kotlin 2.0, leading to a fatal compiler crash.

### How we fixed it:
1.  **Library Downgrade**: We downgraded `androidx.glance` and `androidx.datastore` to version `1.0.0`, which is the last stable version fully compatible with Kotlin 1.9.
2.  **Dependency Pinning**: We added a `resolutionStrategy` in `android/build.gradle.kts` to prevent Gradle from "helpfully" upgrading these libraries to incompatible versions in the future.
3.  **Code Workarounds**: We replaced the inline `currentState<T>()` function in `NeuroLoadWidget.kt` with `GlanceState.getValue()` to avoid the specific code path that triggers the crash.

---

## 2. Windows Environment: Symlink Errors

### What happened?
Even after fixing the Kotlin code, the build failed early with errors related to "symlinks" or "creating directory links."
- **Cause**: Windows requires administrative privileges or **Developer Mode** to create the symbolic links used by the Android/Flutter build process.

### How we fixed it:
- Enabled **Windows Developer Mode** (Settings -> Privacy & security -> For developers).

---

## 3. Quick-Fix Checklist (If it happens again)

If you see a `FunctionCodegen` or `InconsistentAnalysisException` error after adding a new library:

1.  **Check Kotlin Versions**: Ensure no library in your `build.gradle` is compiled with a higher Kotlin version than your project (currently 1.9.24).
2.  **Strict Versioning**: Look at `android/build.gradle.kts`. If a library is causing issues, add it to the `resolutionStrategy` block:
    ```kotlin
    subprojects {
        project.configurations.all {
            resolutionStrategy.eachDependency {
                if (requested.group == "androidx.glance") {
                    useVersion("1.0.0")
                }
            }
        }
    }
    ```
3.  **Clean Build**: Always run `flutter clean` followed by `flutter build apk --release --no-pub` if you change native dependencies.

## 4. Future Upgrades
When you eventually upgrade the project to **Kotlin 2.0+**, you can remove the version pins for Glance and move back to the latest versions (`1.1.x`). Until then, stick to **1.0.0**.

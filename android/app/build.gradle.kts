import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Load key.properties (written by CI or developer locally) ────────────────
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "com.neuroload.neuro_load"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            // Values come from key.properties (CI-injected or local file).
            // Falls back to empty strings so a missing file doesn't crash debug builds.
            keyAlias      = keyProperties["keyAlias"]     as String? ?: ""
            keyPassword   = keyProperties["keyPassword"]  as String? ?: ""
            storeFile     = file(keyProperties["storeFile"] as String? ?: "release.jks")
            storePassword = keyProperties["storePassword"] as String? ?: ""
            // Explicitly declare PKCS12 so AGP 8+ doesn't try to parse as legacy JKS
            // (omitting this causes "Tag number over 30 is not supported" on modern keystores)
            storeType     = keyProperties["storeType"]    as String? ?: "PKCS12"
        }
    }

    defaultConfig {
        applicationId = "com.neuroload.neuro_load"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = if (keyPropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                // Local dev without a keystore: fall back to debug signing.
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

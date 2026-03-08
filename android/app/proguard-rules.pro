# Flutter-specific ProGuard rules
# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep application entry points
-keep class com.neuroload.neuro_load.** { *; }

# Suppress warnings for Flutter internals
-dontwarn io.flutter.**

# Keep Dart/Flutter plugin registrants
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }

# General Android rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# ── Jetpack Glance (Feature 03: home screen widget) ──────────────────────────
# Glance uses reflection to instantiate GlanceAppWidget, GlanceAppWidgetReceiver,
# and ActionCallback subclasses by name. R8 must not rename or remove them.
-keep class androidx.glance.** { *; }
-keep class androidx.glance.appwidget.** { *; }
-keep class androidx.glance.action.** { *; }
-dontwarn androidx.glance.**

# Keep our concrete Glance classes
-keep class com.neuroload.neuro_load.NeuroLoadWidget { *; }
-keep class com.neuroload.neuro_load.NeuroLoadWidgetReceiver { *; }
-keep class com.neuroload.neuro_load.WidgetDistractionCallback { *; }
-keep class com.neuroload.neuro_load.WidgetKeys { *; }

# ── Jetpack DataStore / Preferences (used by Glance widget state) ─────────────
-keep class androidx.datastore.** { *; }
-keep class androidx.datastore.preferences.** { *; }
-dontwarn androidx.datastore.**

# ── Kotlin coroutines (used by Glance + widget state updates) ─────────────────
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# ── Keep obfuscation mapping metadata for crash symbolication ─────────────────
# (--split-debug-info already handles native symbols; this preserves Kotlin
#  line numbers in the mapping file so Firebase Crashlytics / Play can deobfuscate)
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

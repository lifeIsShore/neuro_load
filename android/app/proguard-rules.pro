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

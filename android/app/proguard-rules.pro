# Flutter Proguard Rules

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Sqflite
-keep class com.tekartik.sqflite.** { *; }

# Keep Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep Biometric / Local Auth
-keep class androidx.biometric.** { *; }
-keep class io.flutter.plugins.localauth.** { *; }

# General Android
-keepattributes Signature,Exceptions,InnerClasses
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Fix for potential crashes in release mode
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

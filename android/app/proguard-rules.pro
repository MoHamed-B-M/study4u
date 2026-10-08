# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.engine.** { *; }
-keep class io.flutter.plugins.** { *; }

# Hive
-keep class * extends hive.Object { *; }
-keep class * extends hive.HiveObject { *; }
-keep class com.example.study4u.** { *; }

# Keep JSON serialization classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Play Core (Play Store split install / deferred components)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-keep class com.google.android.play.core.** { *; }

# Keep R8 optimized code paths
-keep,allowobfuscation,allowshrinking class * {
    @keep <fields>;
    @keep <methods>;
}

# Remove unused resource classes
-dontwarn android.support.v4.**
-dontwarn androidx.**

# Optimize: remove unused methods/fields
-optimizationpasses 5
-allowaccessmodification
-mergeinterfacesaggressively
-overloadaggressively

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep reflection for Riverpod code generation
-keep class * extends dev.flutter.* { *; }
-keep class * implements flutter_riverpod.** { *; }

# Keep annotation processor generated code
-keep class * {
    @flutter_riverpod.** <fields>;
    @flutter_riverpod.** <methods>;
}

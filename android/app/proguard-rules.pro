# EMF Meter App ProGuard Rules

# Keep Kotlin metadata for reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes RuntimeVisibleAnnotations

# Hilt
-keepclasseswithmembers class * {
    @dagger.hilt.* <methods>;
}

# Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# Keep shared module classes
-keep class com.emfmeter.domain.** { *; }
-keep class com.emfmeter.data.** { *; }
-keep class com.emfmeter.util.** { *; }

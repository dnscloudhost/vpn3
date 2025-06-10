/**
 * Settings Gradle – Flutter + AGP 8.7 + Kotlin 2.1.0
 */
pluginManagement {
    /* مسیر SDK فلاتر را پیدا می‌کنیم تا flutter_tools را include کنیم */
    val flutterSdkPath = run {
        val p = java.util.Properties()
        file("local.properties").inputStream().use { p.load(it) }
        requireNotNull(p["flutter.sdk"]) { "flutter.sdk not set in local.properties" }.toString()
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

/* اعلام نسخهٔ پلاگین‌ها – apply false یعنی در ماژول‌ها فراخوانی می‌شوند */
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application")          version "8.7.0" apply false
    id("org.jetbrains.kotlin.android")     version "2.1.0" apply false
}

include(":app")

/* ------------------------------------------------------------------ */
/*            ماژول اپ – Kotlin 2.1 ، AGP 8.7 ، SDK 35                 */
/* ------------------------------------------------------------------ */
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")     // بدون version → از classpath می‌خواند
    id("dev.flutter.flutter-gradle-plugin")// همیشه آخر
}

android {
    namespace    = "com.example.mahannn"

    compileSdk   = 35          // هشدارهای پلاگین‌ها
    ndkVersion   = "29.0.13113456"

    defaultConfig {
        applicationId = "com.example.mahannn"
        minSdk        = 23      // برای google-mobile-ads ≥ 5.x
        targetSdk     = 35

        versionCode   = flutter.versionCode
        versionName   = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions { jvmTarget = "17" }

    buildTypes {
        release {
            /* امضای دلخواه – فعلاً همان debug */
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled   = false
            isShrinkResources = false
        }
    }
}

flutter { source = "../.." }

dependencies {
    /* برای API-های java.time در SDK<26 */
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}


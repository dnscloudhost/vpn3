/* ------------------------------------------------------------------ */
/*  Root build.gradle – فقط classpath Kotlin و پیکربندی سراسری        */
/* ------------------------------------------------------------------ */
buildscript {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    dependencies {
        // Kotlin 2.1.0 – همان نسخه‌ای که در settings.gradle.kts اعلام شد
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
    }
}

import com.android.build.gradle.BaseExtension
        import org.gradle.kotlin.dsl.configure
        import org.gradle.api.tasks.Delete

        /* مخازن پیش‌فرض برای همهٔ ماژول‌ها */
        allprojects {
            repositories {
                google()
                mavenCentral()
            }
        }

/* مسیر دلخواه فولدر build (اختیاری) */
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    /* هر ماژول در زیرفولدر مخصوص خود build می‌شود */
    project.layout.buildDirectory.value(newBuildDir.dir(project.name))

    /* اگر namespace در ماژول ست نشده باشد از group استفاده کن */
    plugins.withId("com.android.library") {
        extensions.configure<BaseExtension> {
            if (namespace.isNullOrBlank()) namespace = project.group.toString()
        }
    }
    plugins.withId("com.android.application") {
        extensions.configure<BaseExtension> {
            if (namespace.isNullOrBlank()) namespace = project.group.toString()
        }
    }
}

/* دستور clean */
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

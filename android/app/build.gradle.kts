import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Signing config: environment variables > key.properties
// ---------------------------------------------------------------------------
val keystoreProperties = Properties()

// 1. Try loading from local key.properties (for local builds)
val keyPropsFile = rootProject.file("key.properties")
if (keyPropsFile.exists()) {
    keystoreProperties.load(FileInputStream(keyPropsFile))
}

// 2. Override with environment variables (CI/CD)
System.getenv("KEYSTORE_PATH")?.let { keystoreProperties["storeFile"] = it }
System.getenv("KEYSTORE_PASSWORD")?.let { keystoreProperties["storePassword"] = it }
System.getenv("KEY_ALIAS")?.let { keystoreProperties["keyAlias"] = it }
System.getenv("KEY_PASSWORD")?.let { keystoreProperties["keyPassword"] = it }

android {
    namespace = "com.example.study4u"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.study4u"
        minSdk = 21
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            val storeFileProp = keystoreProperties.getProperty("storeFile")
            if (storeFileProp != null) {
                storeFile = rootProject.file(storeFileProp)
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.findByName("release")?.takeIf {
                (it.storeFile?.exists() == true)
            } ?: signingConfigs.getByName("debug")
        }
    }

    // ABI splits to reduce APK size.
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
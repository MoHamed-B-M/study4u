plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Signing config: environment variables > key.properties
// ---------------------------------------------------------------------------
val keystoreProperties = java.util.Properties()

// 1. Try loading from local key.properties (for local builds)
val keyPropsFile = rootProject.file("key.properties")
if (keyPropsFile.exists()) {
    keystoreProperties.load(java.io.FileInputStream(keyPropsFile))
}

// 2. Override with environment variables (CI/CD)
if (System.getenv("KEYSTORE_PATH") != null) {
    keystoreProperties["storeFile"] = System.getenv("KEYSTORE_PATH")
}
if (System.getenv("KEYSTORE_PASSWORD") != null) {
    keystoreProperties["storePassword"] = System.getenv("KEYSTORE_PASSWORD")
}
if (System.getenv("KEY_ALIAS") != null) {
    keystoreProperties["keyAlias"] = System.getenv("KEY_ALIAS")
}
if (System.getenv("KEY_PASSWORD") != null) {
    keystoreProperties["keyPassword"] = System.getenv("KEY_PASSWORD")
}

android {
    namespace = "com.example.study4u"
    compileSdk = 35
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
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            val storeFileProp = keystoreProperties["storeFile"] as? String
            if (storeFileProp != null) {
                storeFile = rootProject.file(storeFileProp)
                storePassword = keystoreProperties["storePassword"] as? String
                keyAlias = keystoreProperties["keyAlias"] as? String
                keyPassword = keystoreProperties["keyPassword"] as? String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")?.takeIf {
                (it.storeFile?.exists() == true)
            } ?: signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.2")
}

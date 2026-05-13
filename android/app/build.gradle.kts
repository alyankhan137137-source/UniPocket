plugins {
    id("com.android.application")
    id("kotlin-android")
    // Use the modern Flutter Gradle Plugin (compatible with Flutter 3.16+)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Standardized namespace for modern Android builds
    namespace = "com.example.unipocket"
    
    // Updated to 35 as required by jni_flutter
    compileSdk = 36
    
    // Safety: use the Flutter-provided NDK version to match the SDK
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Crucial: Enabled for flutter_local_notifications compatibility
        isCoreLibraryDesugaringEnabled = true
        
        // Java 17 is the current standard for Gradle 8.x + Android builds
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Modern non-deprecated syntax for JVM target
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.unipocket"
        
        // Baseline for modern desugaring and plugin compatibility
        minSdk = flutter.minSdkVersion 
        
        // Updated to 35 to match compileSdk and satisfy plugin requirements
        targetSdk = 35
        
        // Use versioning from pubspec.yaml via Flutter bridge
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Standard test runner for Android Integration tests
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            // Development safety: uses debug keys to allow building without a keystore
            signingConfig = signingConfigs.getByName("debug")
            
            // Modern optimization settings
            isMinifyEnabled = false // Set to true + add proguard-rules.pro for production
            isShrinkResources = false
        }
    }
}

dependencies {
    // Latest stable desugaring library for Java 17 support
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}

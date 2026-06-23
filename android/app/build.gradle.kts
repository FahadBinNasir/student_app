plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin added here
    id("com.google.gms.google-services")
}

android {
    namespace = "com.bukc.student_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Core library desugaring enables modern Java APIs on older devices
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Overridden to your exact specified Package ID
        applicationId = "com.bukc.student" 
        
        // Enforced explicit minimum sdk ceiling requirement
        minSdk = 21 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Crucial for supporting modern date/time formatting functions natively below Android API 26
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
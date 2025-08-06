plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.conecta"

    compileSdk = flutter.compileSdkVersion

    // ✅ Forzamos NDK requerido por Firebase y Stripe
    ndkVersion = "27.0.12077973"

    compileOptions {
        // ✅ Compatibilidad con Java 17 para mejor rendimiento
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    
    // 🚀 Optimizaciones de build
    buildFeatures {
        buildConfig = true
    }
    
    // ⚡ Compresión y optimizaciones
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }

    defaultConfig {
        // ✅ Asegurate de cambiar esto si usás otro dominio
        applicationId = "com.example.conecta"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            // 🔐 Reemplazá esto con tu firma si hacés release
            signingConfig = signingConfigs.getByName("debug")
            
            // ⚡ Optimizaciones release
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            // 🐛 Optimizaciones debug
            isDebuggable = true
            isMinifyEnabled = false
        }
    }
}

flutter {
    source = "../.."
}

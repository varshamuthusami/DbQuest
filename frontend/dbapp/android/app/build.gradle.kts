plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Apply the Google services plugin
}

android {
    namespace = "com.example.dbapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        coreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.dbapp"
        minSdk = 21  // ✅ Minimum recommended SDK for multidex
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true  // ✅ Enable multidex
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")  // Adjust if needed
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1") // ✅ Required for multidex
    
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3") // ✅ Required for desugaring

    implementation(platform("com.google.firebase:firebase-bom:33.11.0")) // Firebase BOM
    implementation("com.google.firebase:firebase-analytics")  // Firebase Analytics
}


plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.shilingfruit.shiling_fruit"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion  // 本地未装 NDK 28.2；依赖插件用预编译 .so

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.shilingfruit.shiling_fruit"
        // You can update the following values to match your application goals.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 仅构建 x86_64（本地开发虚拟机/模拟器），避免下载 arm .so 时网络超时
        // 如需发版到真机请改为 arm64-v8a 或移除整个 ndk 块
        ndk {
            abiFilters += listOf("x86_64")
        }
    }

    ndkVersion = "28.2.13676358"

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

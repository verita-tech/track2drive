plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "de.rentrop.track2drive"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "de.rentrop.track2drive"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    flavorDimensions += listOf("default")

    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }
        create("staging") {
            dimension = "default"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
        }
        create("prod") {
            dimension = "default"
        }
    }

    sourceSets {
        getByName("dev") {
            manifest.srcFile("src/dev/AndroidManifest.xml")
            java.srcDirs("src/dev/java")
            res.srcDirs("src/dev/res")
        }
        getByName("staging") {
            manifest.srcFile("src/staging/AndroidManifest.xml")
            java.srcDirs("src/staging/java")
            res.srcDirs("src/staging/res")
        }
        getByName("prod") {
            manifest.srcFile("src/prod/AndroidManifest.xml")
            java.srcDirs("src/prod/java")
            res.srcDirs("src/prod/res")
        }
    }
}

flutter {
    source = "../.."
}

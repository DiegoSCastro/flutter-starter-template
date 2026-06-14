pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
    // Firebase plugins are commented by default so the template builds
    // without any external configuration. Uncomment the three lines below
    // AFTER you have:
    //   1. Replaced the placeholder `android/app/google-services.json` with
    //      a real config from `flutterfire configure` (see README
    //      "Adding Firebase later").
    //   2. Added the matching `ios/Runner/GoogleService-Info.plist`.
    //   3. Added the Firebase Dart packages back to `pubspec.yaml`
    //      (firebase_core, firebase_analytics, etc).
    // id("com.google.gms.google-services") version "4.4.4" apply false
    // id("com.google.firebase.crashlytics") version "3.0.7" apply false
    // id("com.google.firebase.firebase-perf") version "2.0.2" apply false
}

include(":app")

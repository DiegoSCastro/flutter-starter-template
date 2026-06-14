#!/usr/bin/env bash
# strip_optional.sh
#
# Removes optional service integrations from a fresh Flutter Starter Template
# project, leaving only the core dependency-free stack (BLoC, go_router, DI,
# ObjectBox, ARB localization, get_it, freezed, etc).
#
# What it strips:
#   - Firebase (Gradle plugins + Dart packages + lib/core/platform/firebase/
#     + lib/firebase_options.dart + main.dart calls + injection.config.dart
#     registrations + README references)
#   - AdMob (google_mobile_ads) — currently NOT in template pubspec; this is
#     a no-op but kept here for future-proofing
#   - RevenueCat (purchases_flutter) — currently NOT in template pubspec; no-op
#   - flutter_dotenv / .env loading — currently NOT in template pubspec; no-op
#
# The script is idempotent: run it twice and nothing breaks.
# The script is opt-in: it never runs automatically. You decide.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if [ ! -f "pubspec.yaml" ]; then
  echo "❌ pubspec.yaml not found in $REPO_ROOT. Run this from a Flutter Starter project."
  exit 1
fi

echo "🔧 Stripping optional service integrations from $REPO_ROOT"
echo ""

# ---------------------------------------------------------------------------
# 1. Android Gradle plugins (settings.gradle.kts + app/build.gradle.kts)
# ---------------------------------------------------------------------------
echo "→ [1/6] Disabling Firebase Gradle plugins…"

for gradle in android/settings.gradle.kts android/app/build.gradle.kts; do
  if [ -f "$gradle" ]; then
    # Comment the three plugin lines if they exist and aren't already commented.
    sed -i.bak \
      -e 's|^    id("com.google.gms.google-services")|    // id("com.google.gms.google-services")  // stripped by bin/strip_optional.sh|' \
      -e 's|^    id("com.google.firebase.firebase-perf")|    // id("com.google.firebase.firebase-perf")  // stripped by bin/strip_optional.sh|' \
      -e 's|^    id("com.google.firebase.crashlytics")|    // id("com.google.firebase.crashlytics")  // stripped by bin/strip_optional.sh|' \
      "$gradle"
    rm -f "$gradle.bak"
  fi
done

# ---------------------------------------------------------------------------
# 2. Dart packages in pubspec.yaml
# ---------------------------------------------------------------------------
echo "→ [2/6] Removing Firebase Dart packages from pubspec.yaml…"

if [ -f "pubspec.yaml" ]; then
  sed -i.bak \
    -e 's|^  firebase_core:.*|  # firebase_core: "x.y.z"  # stripped by bin/strip_optional.sh|' \
    -e 's|^  firebase_analytics:.*|  # firebase_analytics: "x.y.z"  # stripped by bin/strip_optional.sh|' \
    -e 's|^  firebase_crashlytics:.*|  # firebase_crashlytics: "x.y.z"  # stripped by bin/strip_optional.sh|' \
    -e 's|^  firebase_performance:.*|  # firebase_performance: "x.y.z"  # stripped by bin/strip_optional.sh|' \
    -e 's|^  firebase_messaging:.*|  # firebase_messaging: "x.y.z"  # stripped by bin/strip_optional.sh|' \
    -e 's|^  firebase_remote_config:.*|  # firebase_remote_config: "x.y.z"  # stripped by bin/strip_optional.sh|' \
    -e 's|^  google_mobile_ads:.*|  # google_mobile_ads: "x.y.z"  # stripped by bin/strip_optional.sh|' \
    -e 's|^  purchases_flutter:.*|  # purchases_flutter: "x.y.z"  # stripped by bin/strip_optional.sh|' \
    -e 's|^  flutter_dotenv:.*|  # flutter_dotenv: "x.y.z"  # stripped by bin/strip_optional.sh|' \
    pubspec.yaml
  rm -f pubspec.yaml.bak
fi

# ---------------------------------------------------------------------------
# 3. lib/core/platform/firebase/ — remove if empty
# ---------------------------------------------------------------------------
echo "→ [3/6] Removing lib/core/platform/firebase/…"

if [ -d "lib/core/platform/firebase" ]; then
  rm -rf lib/core/platform/firebase
  echo "   removed lib/core/platform/firebase/"
fi

# ---------------------------------------------------------------------------
# 4. lib/firebase_options.dart — remove placeholder
# ---------------------------------------------------------------------------
echo "→ [4/6] Removing lib/firebase_options.dart…"

if [ -f "lib/firebase_options.dart" ]; then
  rm -f lib/firebase_options.dart
  echo "   removed lib/firebase_options.dart"
fi

# ---------------------------------------------------------------------------
# 5. main.dart — comment out Firebase calls
#    Operator: replace bootstrap section with try-with-no-firebase.
#    We do not rewrite main.dart automatically; instead we emit a manual
#    patch file so the user can see exactly what to delete.
# ---------------------------------------------------------------------------
echo "→ [5/6] Writing main.dart.fix to show required manual edits…"

cat > main.dart.fix <<'EOF'
# In lib/main.dart, replace the body of main() with:
#
#   try {
#     await configureDependencies();
#     await getIt<KeychainResetOnReinstall>().run();
#     // Firebase + RemoteConfig + Messaging were stripped by bin/strip_optional.sh.
#     // Re-add them here when you wire Firebase back in (see README).
#     await getIt<NotificationsService>().init();
#     runApp(const App());
#   } on Object catch (error, stackTrace) {
#     developer.log('App bootstrap failed', name: 'bootstrap',
#       level: 1000, error: error, stackTrace: stackTrace);
#     runApp(BootstrapErrorApp(error: error));
#   }
#
# And remove the `_reportBootstrapFailure` helper (it references Crashlytics).
# Also remove the `package:firebase_core/firebase_core.dart` import.
EOF

echo "   see main.dart.fix"

# ---------------------------------------------------------------------------
# 6. DI / injection.config.dart — regenerate
# ---------------------------------------------------------------------------
echo "→ [6/6] Regenerating DI / injection.config.dart via build_runner…"

if [ -d ".dart_tool" ]; then
  dart run build_runner build --delete-conflicting-outputs 2>&1 | tail -5 || \
    echo "   ⚠ build_runner failed — run it manually after stripping"
fi

echo ""
echo "✅ Done. To re-enable Firebase later:"
echo "   1. Uncomment the 3 lines in android/settings.gradle.kts"
echo "   2. Uncomment the 3 lines in android/app/build.gradle.kts"
echo "   3. Uncomment the Dart packages in pubspec.yaml"
echo "   4. Run \`flutterfire configure\` to generate firebase_options.dart"
echo "   5. Restore the Firebase init calls in main.dart (see main.dart.fix)"

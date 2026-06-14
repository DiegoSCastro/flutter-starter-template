# Changelog

All notable changes to this template are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Clean-start by default**: `pubspec.yaml`, `android/settings.gradle.kts`
  and `android/app/build.gradle.kts` now ship with the Firebase Gradle
  plugins and the optional Dart packages (`firebase_core`, `firebase_*`,
  `google_mobile_ads`, `purchases_flutter`, `flutter_dotenv`) **commented
  out by default**. A freshly scaffolded project builds and runs on
  Android and iOS without any external service configuration.
- **`bin/strip_optional.sh`**: new opt-in script to retroactively strip
  Firebase / AdMob / RevenueCat / `flutter_dotenv` from an existing
  project. Idempotent.
- **`assets/main.dart`**: minimal `ScaffoldApp` entry point used by
  `bin/create_from_template.sh` to overwrite the template's
  Firebase-coupled `lib/main.dart`.

### Changed

- `bin/create_from_template.sh` now also comments the Firebase Gradle
  plugins and the optional Dart packages in the cloned project (in
  addition to deleting `lib/firebase_options.dart` and
  `lib/core/platform/firebase/`).
- `lib/main.dart` was renamed/moved to `assets/main.dart`. The scaffolded
  project receives the minimal `ScaffoldApp`, not the Firebase-wired
  `App()`.
- README "Firebase" section replaced with "Optional Services (Firebase /
  AdMob / RevenueCat / dotenv)" explaining the new opt-in flow.
- **Swift Package Manager disabled by default**:
  `pubspec.yaml` now sets `flutter: config: enable-swift-package-manager: false`,
  the four Xcode schemes (`Runner`, `dev`, `prod`, `staging`) no longer
  carry the `xcode_backend.sh prepare` PreAction, and all SPM references
  (`FlutterGeneratedPluginSwiftPackage`, `XCLocalSwiftPackageReference`,
  `XCSwiftPackageProductDependency`, the `packageReferences` and
  `packageProductDependencies` blocks) are stripped from
  `ios/Runner.xcodeproj/project.pbxproj`. CocoaPods is now the only iOS
  plugin resolver at scaffold time, matching what the upstream plugins
  (`home_widget`, `share_plus`, `url_launcher_android`'s iOS counterpart)
  actually support.
- **FVM removed**: `.fvmrc` deleted, `.fvm/` and `.fvm_bin/` removed from
  `.gitignore`, and every reference to FVM rewritten to use the plain
  `flutter` / `dart` binaries (`.githooks/pre-push`, `tool/setup.sh`,
  `AGENTS.md`, `CLAUDE.md`, `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`,
  `.antigravity/rules.md`, `.antigravity/mcp.json`, `.mcp.json`, the
  GitHub workflows, the README files under `lib/`, `test/`, `integration_test/`,
  `doc/`, `packages/`, `ios/`, `android/`, the Fastlane `Fastfile`s and
  `.env.example`s, and the comment headers in `dart_test.yaml`,
  `test/architecture/*_test.dart`, `test_driver/integration_test.dart`,
  `integration_test/screenshots_test.dart`, and `tool/run_e2e.sh`).

### Fixed

- **`bin/create_from_template.sh` Android bug**: the script rewrote
  `applicationId` / `namespace` in `android/app/build.gradle.kts` but
  left the Kotlin source tree under the legacy package
  `com.lucistudio.flutter_starter_template`. The scaffolded project
  failed to build on Android with "package R does not exist" /
  "MainActivity is not registered". The script now renders
  `assets/android/MainActivity.kt` (with the `__PACKAGE__` placeholder
  substituted to `com.<org_id>`) at the new package path, mirroring
  the iOS `Info.plist` / `.pbxproj` rewrite. The `lib/main.dart`
  copy is moved to **after** the `rm -f lib/main.dart` strip step
  so the scaffold actually receives a `main.dart` to compile.
- **`--local` mode**: `bin/create_from_template.sh` now accepts
  `--local`, which copies the current working tree instead of cloning
  from `origin`. Useful when iterating on the template itself — the
  fix you just wrote is the version you test, not the version on
  `origin/main`.

## [1.0.0] - 2026-06-08

First stable release of the Flutter starter template.

### Added

- **Project foundation** — Flutter SDK pinned to 3.44.0, lints via
  `very_good_analysis`, and a feature-first `core` / `ui` / `shared` / `features`
  layout (see `CLAUDE.md`).
- **State management & routing** — `flutter_bloc` (+ `bloc_concurrency`) for app
  state and `go_router` for declarative navigation.
- **Dependency injection** — `injectable`/`get_it` wiring, including the
  per-package micro-DI pattern.
- **Workspace packages** — extracted into `packages/`: `analytics`,
  `app_platform`, `app_ui`, `architecture`, `config`, `network`, `storage`,
  `sync`, `theme`, plus `test_utils`.
- **Features** — `splash`, `auth`, `home`, `profile`, `bookmarks`,
  `collections`, and `notifications`, with a shared `Session` contract for
  app-wide auth state.
- **Theming & design system** — centralized light/dark `ThemeData` with a
  `ThemeBloc` toggle and the `app_ui` design-system widgets.
- **Local persistence** — ObjectBox storage with tracked schema bindings.
- **Flavors** — `dev` / `staging` / `prod` build flavors driven by
  `--dart-define-from-file env/<flavor>.json`.
- **Firebase** — integration with Crashlytics and analytics (CocoaPods on iOS;
  SPM disabled, see `CLAUDE.md`).
- **Internationalization** — `flutter_localizations` + `intl` with ARB-based
  localizations.
- **CI/CD** — GitHub Actions for analyze/test with coverage gating (`ci.yml`),
  CodeQL (`codeql.yml`), and a manual-dispatch Fastlane release pipeline
  (`release.yml`) for TestFlight and Google Play.
- **Bootstrap CLI** — `tool/setup.sh`, a one-command idempotent setup
  (submodules, disable SPM on macOS, `pub get`, code generation,
  backend deps, and the pre-push hook).
- **Tooling** — Dart & CodeGraph MCP servers and vendored agent skills.

[1.0.0]: https://github.com/kido-luci/flutter-starter-template/releases/tag/v1.0.0

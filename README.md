<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://img.shields.io/badge/Flutter-3.44+-02569B?style=for-the-badge&logo=flutter&logoColor=white">
    <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.44+-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  </picture>
  <a href="https://github.com/kido-luci/flutter-starter-template/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge"></a>
  <a href="https://luci-studio.com"><img alt="Luci" src="https://img.shields.io/badge/built_by-Luci_Studio-FF6B6B?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJ3aGl0ZSIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiPjxyZWN0IHg9IjMiIHk9IjMiIHdpZHRoPSIxOCIgaGVpZ2h0PSIxOCIgcng9IjIiIHJ5PSIyIi8+PGNpcmNsZSBjeD0iOSIgY3k9IjkiIHI9IjIiLz48bGluZSB4MT0iMTIuMSIgeTE9IjkuMSIgeDI9IjE1IiB5Mj0iMTUiLz48L3N2Zz4="></a>
</p>

<h1 align="center">
  <br>
  <img src="https://img.shields.io/badge/🚀-Flutter_Starter_Template-02569B?style=flat-square&labelColor=121212" alt="Logo">
  <br>
</h1>

<p align="center">
  <i>A production‑ready Flutter foundation with Clean Architecture,<br>offline‑first sync, JWT auth, Firebase, and a companion Go backend.</i>
</p>

<p align="center">
  <img src="doc/images/Flutter%20Starter%20Template.png" alt="Flutter Starter Template Banner" width="800">
</p>

<br>

**Flutter Starter Template**, built by [Luci Studio](https://luci-studio.com), is an enterprise-grade mobile boilerplate engineered for building scalable, high-performance cross-platform applications. It solves the complex challenges of bootstrapping new projects by providing a production-ready structure out of the box. This template features strict Clean Architecture layers, robust offline-first synchronization, secure JWT credential lifecycle management, and pre-configured Firebase integrations.

To enable seamless local development and testing, this template is paired with a companion in-memory backend server written in Go, allowing you to test authentication flows, CRUD operations, and sync conflict resolution under real network conditions.

<br>

---

<br>

## ✨ What's Inside

|                           |                            |
|---------------------------|----------------------------|
| 🏛 **Clean Architecture** | Data / domain / presentation layers with full dependency inversion |
| 🧩 **BLoC + Freezed**     | Bloc pattern with sealed state unions and exhaustive `when` |
| 📶 **Offline‑First**      | ObjectBox local writes → bidirectional sync on reconnect → share → link previews |
| 🔐 **JWT Auth**           | Access + refresh tokens, auto‑refresh interceptor, secure storage |
| 🧭 **Declarative Routing**| `go_router` with typed routes, auth guards, Universal Links & App Links |
| 🎨 **Theming**            | Material 3, `FlexColorScheme`, Google Fonts (Inter), true black OLED dark mode |
| 🌐 **i18n**               | ARB‑based localization — English + Vietnamese out of the box |
| 🔥 **Firebase**           | Crashlytics, Analytics, Messaging — all wired up |
| 🔔 **Notifications**      | On‑device scheduling + tap‑to‑navigate |
| 💉 **DI**                 | `get_it` + `injectable` code‑gen — zero manual wiring |
| 📡 **REST**               | `Retrofit` + `Dio` typed clients with auth interceptor |
| ⚙️ **Go Backend**         | Companion server — `chi/v5`, JWT issuer, bookmark CRUD |
| 🤖 **AI-Native**          | Rules, MCP servers, and agent skills for Claude, Cursor, Codex, Command Code, and Antigravity |

<br>

---

<br>

## 🧬 Architecture

```
lib/
├── main.dart                         # Entry: DI → Firebase → runApp
├── app/
│   ├── app.dart                      # MaterialApp.router + providers
│   └── router.dart                   # TypedGoRoute + auth redirect
├── core/
│   ├── analytics/                    # Firebase Analytics wrapper + route observer
│   ├── animation/                    # Shared transitions + motion helpers
│   ├── bloc/                         # BLoC event completion and nullable completer utilities
│   ├── build_context_extensions.dart # Theme/MediaQuery shortcuts on BuildContext
│   ├── config/                       # EnvConfig — typed --dart-define values
│   ├── di/                           # get_it + injectable
│   ├── error/                        # Failure hierarchy
│   ├── firebase/                     # Firebase initialization & global Crashlytics/Messaging setup
│   ├── media/                        # Camera, Image Picker, and Video Player wrapper services
│   ├── network/                      # Dio clients, auth interceptor, token refresh
│   ├── notifications/                # flutter_local_notifications
│   ├── permissions/                  # Runtime permission request handling
│   ├── share/                        # share_plus wrapper
│   ├── theme/                        # ThemeBloc + light/dark ThemeData
│   ├── usecases/                     # Abstract UseCase base class
│   ├── utils/                        # Result<T> type
│   └── widgets/                      # Reusable UI components
├── features/
│   ├── auth/                         # Sign-in, sign-out, session restore
│   ├── bookmarks/                    # CRUD, offline sync, list/detail/form
│   ├── home/                         # Welcome screen
│   ├── profile/                      # User info, theme toggle, notifications
│   └── splash/                       # Session restoration gate
├── gen/                              # flutter_gen asset references
└── l10n/                             # ARB translation files
```

<details>
<summary><b>📁 Feature Slice (Clean Architecture)</b></summary>
<br>

```
feature/
├── data/
│   ├── datasources/        Remote (Retrofit) + Local (ObjectBox / secure storage)
│   ├── models/             Freezed DTOs with toDomain() mappers
│   └── repositories/       Concrete implementations
├── domain/
│   ├── entities/           Pure Dart classes — zero framework deps
│   ├── repositories/       Abstract interfaces
│   └── usecases/           Single‑purpose, injectable
└── presentation/
    ├── bloc/               Bloc + freezed state
    └── screens/            Stateless/Stateful widgets
```

</details>

<br>

---

<br>

## 🚀 Quick Start

### 📋 Prerequisites

| Tool    | Version | Notes |
|---------|---------|-------|
| Flutter | ≥ 3.44  | Managed via [FVM](https://fvm.app/) — see `.fvmrc` |
| Go      | ≥ 1.25  | Backend server |

### ⚡ Install & Generate

```bash
git clone https://github.com/kido-luci/flutter-starter-template.git
cd flutter-starter-template

fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
```

### 🍎 iOS one-time setup

iOS builds must use CocoaPods, **not** Swift Package Manager — Firebase needs an
iOS 15.0 deployment target, but Flutter 3.44.0 hardcodes the SPM-generated
package to 13.0, and two plugins (`permission_handler_apple`,
`objectbox_flutter_libs`) don't support SPM yet. This setting lives in a
machine-global Flutter config (`~/.config/flutter/settings`), so **every new
machine and CI runner must run it once** before the first iOS build:

```bash
fvm flutter config --no-enable-swift-package-manager
```

### 🖥 Start Backend

```bash
cd simple_backend_server
go run .                    # → http://localhost:8080
```

| Method   | Endpoint                   | Description               |
|----------|----------------------------|---------------------------|
| `GET`    | `/health`                  | Health check              |
| `POST`   | `/api/auth/sign-in`        | Sign in                   |
| `POST`   | `/api/auth/refresh`        | Refresh access token      |
| `POST`   | `/api/auth/sign-out`       | Revoke refresh token      |
| `GET`    | `/api/auth/me`             | Current user              |
| `GET`    | `/api/bookmarks`           | List bookmarks            |
| `POST`   | `/api/bookmarks`           | Create bookmark           |
| `GET`    | `/api/bookmarks/:id`       | Get bookmark              |
| `PUT`    | `/api/bookmarks/:id`       | Update bookmark           |
| `DELETE` | `/api/bookmarks/:id`       | Delete bookmark           |

> 💡 **Tip** — Any username + password works during development.

### 📱 Launch App

```bash
fvm flutter run
```

<br>

## 🧪 Testing & Code Quality

This template includes a robust set of automated tests and static analysis configuration to ensure code quality.

### 🏃 Running Tests

Unit and widget tests mirror the `lib/` directory structure. Run them using:

```bash
# Run all unit and widget tests
fvm flutter test

# Run a specific test file
fvm flutter test test/widget_test.dart

# Run tests by name match
fvm flutter test --name "signs in"
```

Refer to the [test/README.md](file:///Users/trunglaptieu/development/projects/flutter-starter-template/test/README.md) file for detailed testing guidelines and patterns.

### 🔍 Static Analysis & Linting

Verify lint rules, formatting, and type safety before committing:

```bash
# Analyze code for warnings and errors
fvm flutter analyze

# Automatically apply quick fixes
fvm dart fix --apply

# Format all Dart files
fvm flutter format .
```

<br>

---

<br>

## 🔥 Firebase

Crashlytics + Analytics + Messaging — pre‑configured and ready to connect.

```bash
fvm dart pub global activate flutterfire_cli
flutterfire configure                          # → lib/firebase_options.dart
```

Drop these into your project:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Firebase initializes in `lib/main.dart` with Crashlytics fatal‑error reporting on both Flutter and platform threads.

<br>

---

<br>

## 🍦 Flavors & Environment

Three build flavors driven by `--dart-define` with typed runtime config:

| Flavor    | Android App ID                                      |
|-----------|-----------------------------------------------------|
| `dev`     | `com.lucistudio.flutter_starter_template.dev`       |
| `staging` | `com.lucistudio.flutter_starter_template.staging`   |
| `prod`    | `com.lucistudio.flutter_starter_template`           |

```bash
fvm flutter run --flavor dev     --dart-define-from-file=env/dev.json
fvm flutter run --flavor staging --dart-define-from-file=env/staging.json
fvm flutter run --flavor prod    --dart-define-from-file=env/prod.json
```

`EnvConfig` (`lib/core/config/env_config.dart`) surfaces API base URL, Firebase project IDs, and flavor name from `String.fromEnvironment` at startup.

<br>

---

<br>

## 🔗 Deep Linking

Universal Links (iOS) + App Links (Android) with a `DeepLinkState` holder that replays deferred links post‑auth.

<details>
<summary><b>📁 Config files to update</b></summary>
<br>

| Platform  | File                                    |
|-----------|-----------------------------------------|
| Android   | `android/app/src/main/AndroidManifest.xml` |
| iOS       | `ios/Runner/Info.plist`                 |
| iOS       | `ios/Runner/Runner*.entitlements`       |

Replace `yourdomain.com` with your actual domain, then host these on your server:

**`/.well-known/apple-app-site-association`**
```json
{
  "applinks": {
    "apps": [],
    "details": [{
      "appIDs": ["TEAM_ID.com.luci-studio.flutterStarterTemplate"],
      "paths": ["*"]
    }]
  }
}
```

**`/.well-known/assetlinks.json`**
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.lucistudio.flutter_starter_template",
    "sha256_cert_fingerprints": ["YOUR_SHA256"]
  }
}]
```

</details>

<br>

---

<br>

## 🧩 Core Widgets

All shared components in `lib/core/widgets/`:

| Widget              | Purpose                                                          |
|---------------------|------------------------------------------------------------------|
| `AppAnimatedText`   | Typewriter + fade text animations                                |
| `AppButton`         | Loading state, expand‑to‑fill, leading icon                      |
| `AppCarousel`       | Auto‑play slider with dot indicators                             |
| `AppEmptyView`      | Empty‑state placeholder — icon + message                         |
| `AppErrorView`      | Error state — icon + message + retry                             |
| `AppLinkPreview`    | Rich card — image, title, description                            |
| `AppLoading`        | Centered spinner                                                 |
| `AppNetworkImage`   | Cached network image with loading placeholder and error widgets  |
| `AppPhotoView`      | Interactive image viewer with zoom, rotation, and fullscreen gallery |
| `AppScaffold`       | Themed shell — app bar, connectivity banner                      |
| `AppSlidable`       | Swipe‑to‑reveal actions wrapper for list items                    |
| `AppTextField`      | Label, prefix icon, validation, autofill hints                   |
| `AppVideoPlayer`    | Customizable video player with progress controls and audio controls |

<br>

---

<br>

## 🧰 Tech Stack

| Layer              | Packages                                                                                           |
|--------------------|----------------------------------------------------------------------------------------------------|
| **State**          | `flutter_bloc` (Bloc) · `bloc_concurrency`                                                         |
| **Routing**        | `go_router` · `go_router_builder`                                                                  |
| **DI**             | `get_it` · `injectable`                                                                            |
| **Networking**     | `Dio` · `Retrofit`                                                                                 |
| **Code Gen**       | `build_runner` · `freezed` · `json_serializable` · `retrofit_generator` · `injectable_generator` · `go_router_builder` · `flutter_gen_runner` · `objectbox_generator` |
| **Local DB**       | `ObjectBox` (`objectbox` · `objectbox_flutter_libs`)                                               |
| **Secure Storage** | `flutter_secure_storage`                                                                           |
| **Auth**           | JWT — access + refresh tokens                                                                      |
| **Theming**        | Material 3 · `flex_color_scheme` · `google_fonts` (Inter)                                          |
| **i18n**           | `flutter_localizations` · `intl`                                                                   |
| **Icons**          | `cupertino_icons`                                                                                  |
| **Assets**         | `flutter_svg` · `flutter_gen_runner`                                                               |
| **Image / Media**  | `photo_view` · `image_picker` · `camera` · `video_player` · `cached_network_image` · `vector_graphics` |
| **Carousel**       | `carousel_slider`                                                                                  |
| **List Slidables** | `flutter_slidable`                                                                                 |
| **Permissions**    | `permission_handler`                                                                               |
| **Notifications**  | `flutter_local_notifications`                                                                      |
| **Firebase**       | `firebase_core` · `firebase_crashlytics` · `firebase_analytics` · `firebase_messaging`             |
| **Animations**     | `flutter_animate` · `animated_text_kit`                                                            |
| **Haptics**        | `HapticFeedback` (Flutter Services)                                                                |
| **Connectivity**   | `connectivity_plus`                                                                                |
| **Storage**        | `path_provider` · `shared_preferences`                                                             |
| **Device Info**    | `package_info_plus`                                                                                |
| **URL**            | `url_launcher`                                                                                     |
| **Share**          | `share_plus`                                                                                       |
| **Link Preview**   | `flutter_link_previewer`                                                                           |
| **UUID**           | `uuid`                                                                                             |
| **Splash**         | Custom session-restore bootstrapper (no package)                                                   |
| **Testing & Lints**| `mocktail` · `bloc_test` · `very_good_analysis` · `build_verify`                                        |
| **Backend**        | Go — `chi/v5` · `golang-jwt/v5` · `cors`                                                          |

<br>

---

<br>

## 🤖 AI‑Native Workflow

This project is built for AI‑assisted development with **Command Code**, Claude Code, Codex, Cursor, and Antigravity.

### 🎯 Command Code — Taste & Plans

Learned project preferences in `.commandcode/taste/` auto‑guide every agent:

| Domain               | Convention                                                  |
|----------------------|-------------------------------------------------------------|
| Flutter Packages     | Package selection preferences                               |
| Architecture         | Layered architecture, feature‑slice conventions             |
| Backend              | Go + `go-chi` router                                        |
| Flutter Setup        | l10n · light/dark theming · `--dart-define` flavors         |
| Documentation        | Include Command Code alongside other AI tools in rules      |
| Testing              | Extract shared mocks/fakes into reusable test helpers       |

Architectural plans live in `.commandcode/plans/`.

### 🧪 MCP Servers

Project‑scoped MCP servers in `.mcp.json` give agents direct access to:

| Server      | Command                                        | Purpose                                      |
|-------------|------------------------------------------------|----------------------------------------------|
| `dart`      | `fvm dart mcp-server`                          | Static analysis, formatting, packages, tests |
| `codegraph` | `codegraph serve --mcp --path <project-root>` | Symbol search, callers/callees, code context |

> 💡 **Tip** — If the CodeGraph index is missing or out of sync, build/update it by running:
> ```bash
> codegraph init -i
> ```

### 📜 Rules Files

| Tool            | File                        |
|-----------------|-----------------------------|
| Command Code    | `.commandcode/taste/`       |
| Command Code    | `.commandcode/plans/`       |
| Codex           | `AGENTS.md`                 |
| Claude Code     | `CLAUDE.md`                 |
| Cursor          | `.cursor/rules/`            |
| Antigravity     | `.antigravityrules`         |

### 🛠 Agent Skills

Official playbooks from `flutter/skills` and `dart-lang/skills` are vendored in `.agents/skills/` and pinned in `skills-lock.json`.

<details>
<summary><b>🦋 Flutter Skills</b> (10)</summary>
<br>

| Skill                                   | Focus                            |
|-----------------------------------------|----------------------------------|
| `flutter-setup-declarative-routing`     | `go_router` + typed routes       |
| `flutter-implement-json-serialization`  | `fromJson` / `toJson`            |
| `flutter-add-widget-test`               | `WidgetTester` component tests   |
| `flutter-add-widget-preview`            | Interactive widget previews      |
| `flutter-add-integration-test`          | `integration_test`               |
| `flutter-apply-architecture-best-practices` | UI / Logic / Data layers     |
| `flutter-build-responsive-layout`       | `LayoutBuilder` · `MediaQuery`   |
| `flutter-fix-layout-issues`             | Overflow · unbounded constraints |
| `flutter-setup-localization`            | `intl` + ARB                     |
| `flutter-use-http-package`              | REST API integration             |

</details>

<details>
<summary><b>🎯 Dart Skills</b> (9)</summary>
<br>

| Skill                                | Focus                                  |
|--------------------------------------|----------------------------------------|
| `dart-add-unit-test`                 | `package:test` unit tests              |
| `dart-run-static-analysis`           | `dart analyze` + `dart fix`            |
| `dart-fix-runtime-errors`            | Stack trace diagnostics                |
| `dart-generate-test-mocks`           | `mockito` + `build_runner`             |
| `dart-collect-coverage`              | LCOV coverage reports                  |
| `dart-build-cli-app`                 | CLI entrypoints · exit codes           |
| `dart-resolve-package-conflicts`     | `pub get` conflict resolution          |
| `dart-migrate-to-checks-package`     | `matcher` → `checks` migration         |
| `dart-use-pattern-matching`          | Switch expressions · pattern matching  |

</details>

<br>

---

<br>

## 🔄 Code Generation

```bash
fvm dart run build_runner build --delete-conflicting-outputs   # one-shot
fvm dart run build_runner watch --delete-conflicting-outputs   # incremental
```

Runs Freezed, Retrofit, Injectable, ObjectBox, `go_router_builder`, `flutter_gen`, and `json_serializable`. Generated files are tracked in git — adjust `.gitignore` if your team prefers otherwise.

<br>

## 🌐 Localization (i18n)

Translations are managed using ARB (Application Resource Bundle) files located under [lib/l10n/](file:///Users/trunglaptieu/development/projects/flutter-starter-template/lib/l10n/).

### 🛠 Generating Translations

Since `generate: true` is enabled in [pubspec.yaml](file:///Users/trunglaptieu/development/projects/flutter-starter-template/pubspec.yaml), Flutter automatically updates the generated localization files whenever you run packages commands:

```bash
# Generate localization resources manually
fvm flutter gen-l10n
```

Import `package:flutter_gen/gen_l10n/app_localizations.dart` and use `AppLocalizations.of(context)` to access localized strings.

<br>

---

<br>

<p align="center">
  <sub>Made with ❤️ by <a href="https://luci-studio.com">Luci Studio</a></sub>
  <br><br>
  <a href="https://github.com/kido-luci/flutter-starter-template/blob/main/LICENSE">
    <img alt="MIT" src="https://img.shields.io/badge/license-MIT-brightgreen?style=flat-square">
  </a>
</p>

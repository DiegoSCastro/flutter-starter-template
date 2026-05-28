<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://img.shields.io/badge/Flutter-3.44+-02569B?style=for-the-badge&logo=flutter&logoColor=white">
    <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.44+-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  </picture>
  <a href="https://github.com/kido-luci/flutter-starter-template/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge"></a>
  <a href="https://lucistudio.com"><img alt="Luci" src="https://img.shields.io/badge/built_by-Luci_Studio-FF6B6B?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJ3aGl0ZSIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiPjxyZWN0IHg9IjMiIHk9IjMiIHdpZHRoPSIxOCIgaGVpZ2h0PSIxOCIgcng9IjIiIHJ5PSIyIi8+PGNpcmNsZSBjeD0iOSIgY3k9IjkiIHI9IjIiLz48bGluZSB4MT0iMTIuMSIgeTE9IjkuMSIgeDI9IjE1IiB5Mj0iMTUiLz48L3N2Zz4="></a>
</p>

<h1 align="center">
  <br>
  <img src="https://img.shields.io/badge/🚀-Flutter_Starter_Template-02569B?style=flat-square&labelColor=121212" alt="Logo">
  <br>
</h1>

<p align="center">
  <i>A production‑ready Flutter foundation with Clean Architecture,<br>offline‑first sync, JWT auth, Firebase, and a companion Go backend.</i>
</p>

<br>

---

<br>

## ✨ What's Inside

|                           |                            |
|---------------------------|----------------------------|
| 🏛 **Clean Architecture** | Data / domain / presentation layers with full dependency inversion |
| 🧩 **BLoC + Freezed**     | Cubit pattern with sealed state unions and exhaustive `when` |
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
│   ├── build_context_extensions.dart # Theme/MediaQuery shortcuts on BuildContext
│   ├── config/                       # EnvConfig — typed --dart-define values
│   ├── di/                           # get_it + injectable
│   ├── error/                        # Failure hierarchy
│   ├── network/                      # Dio clients, auth interceptor, token refresh
│   ├── notifications/                # flutter_local_notifications
│   ├── permissions/                  # Runtime permission request handling
│   ├── share/                        # share_plus wrapper
│   ├── theme/                        # ThemeCubit + light/dark ThemeData
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
    ├── cubit/              Cubit + freezed state
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
| `AppScaffold`       | Themed shell — app bar, connectivity banner                      |
| `AppButton`         | Loading state, expand‑to‑fill, leading icon                      |
| `AppTextField`      | Label, prefix icon, validation, autofill hints                   |
| `AppCarousel`       | Auto‑play slider with dot indicators                             |
| `AppLinkPreview`    | Rich card — image, title, description                            |
| `AppAnimatedText`   | Typewriter + fade text animations                                |
| `AppLoading`        | Centered spinner                                                 |
| `AppEmptyView`      | Empty‑state placeholder — icon + message                         |
| `AppErrorView`      | Error state — icon + message + retry                             |
| `AppSlidable`       | Swipe‑to‑reveal actions wrapper for list items                    |

<br>

---

<br>

## 🧰 Tech Stack

| Layer              | Packages                                                                                           |
|--------------------|----------------------------------------------------------------------------------------------------|
| **State**          | `flutter_bloc` (Cubit)                                                                             |
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

---

<br>

<p align="center">
  <sub>Made with ❤️ by <a href="https://lucistudio.com">Luci Studio</a></sub>
  <br><br>
  <a href="https://github.com/kido-luci/flutter-starter-template/blob/main/LICENSE">
    <img alt="MIT" src="https://img.shields.io/badge/license-MIT-brightgreen?style=flat-square">
  </a>
</p>

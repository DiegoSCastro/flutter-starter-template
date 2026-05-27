# Flutter Starter Template

A production-ready Flutter starter template built by [Luci](https://lucistudio.com). Batteries included: Clean Architecture, offline-first sync, JWT auth, Firebase, i18n, theming, and a companion Go backend — everything you need to ship fast.

## ✨ Features

- **Clean Architecture** — data, domain, and presentation layers with dependency inversion
- **BLoC state management** — Cubit pattern with freezed sealed state unions
- **Offline-first bookmarks** — local ObjectBox writes, bidirectional sync on reconnect, share, and link previews
- **JWT authentication** — access + refresh tokens, auto-refresh interceptor, secure storage
- **Declarative routing & deep linking** — go_router with typed routes, auth redirect guards, Universal Links (iOS) and App Links (Android)
- **Dark / light / system theming** — Material 3, FlexColorScheme, Google Fonts (Inter)
- **Localization** — ARB-based i18n with English and Vietnamese
- **Firebase** — Crashlytics for crash reporting, Analytics for usage tracking
- **Local notifications** — on-device scheduling and display
- **Dependency injection** — get_it + injectable with code generation
- **REST networking** — Retrofit + Dio with typed API clients
- **Go backend** — companion server with chi router, JWT issuer, bookmark CRUD

## 🏗 Architecture

```
lib/
├── main.dart                    # Entry point: DI, Firebase, run App
├── app/                         # App shell + routing
│   ├── app.dart                 # MaterialApp.router with providers
│   └── router.dart              # TypedGoRoute + auth redirect
├── core/                        # Cross-cutting concerns
│   ├── di/                      # get_it + injectable
│   ├── error/                   # Failure hierarchy
│   ├── network/                 # Dio clients, auth interceptor, token refresh
│   ├── notifications/           # flutter_local_notifications
│   ├── theme/                   # ThemeCubit + light/dark ThemeData
│   ├── utils/                   # Result<T> type
│   └── widgets/                 # Reusable UI components
├── features/                    # Vertical feature slices
│   ├── auth/                    # Sign-in, sign-out, session restore
│   ├── bookmarks/               # CRUD, offline sync, list/detail/form screens
│   ├── home/                    # Welcome screen
│   ├── profile/                 # User info, theme toggle, notifications
│   └── splash/                  # Session restoration gate
├── gen/                         # flutter_gen asset references
└── l10n/                        # ARB translation files
```

Each feature follows Clean Architecture:

```
feature/
├── data/
│   ├── datasources/    # Remote (Retrofit) + local (ObjectBox / secure storage)
│   ├── models/         # Freezed DTOs with toDomain() mappers
│   └── repositories/   # Concrete implementations
├── domain/
│   ├── entities/       # Pure Dart classes, no framework dependencies
│   ├── repositories/   # Abstract interfaces
│   └── usecases/       # Single-purpose injectable classes
└── presentation/
    ├── cubit/          # Cubit + freezed state
    └── screens/        # Stateless/Stateful widgets
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.44 (managed via [FVM](https://fvm.app/) — see `.fvmrc`)
- Go ≥ 1.25 (for the backend server)

### Setup

```bash
# Clone the repo
git clone https://github.com/your-org/flutter-starter-template.git
cd flutter-starter-template

# Install Flutter dependencies
flutter pub get

# Generate code (routes, DI, models, assets, ObjectBox)
dart run build_runner build --delete-conflicting-outputs
```

### Run the backend

```bash
cd simple_backend_server
go run .
# Server starts on http://localhost:8080
```

Endpoints:

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Health check |
| `POST` | `/api/auth/sign-in` | Sign in (any username + password) |
| `POST` | `/api/auth/refresh` | Refresh access token |
| `POST` | `/api/auth/sign-out` | Revoke refresh token |
| `GET` | `/api/auth/me` | Get current user |
| `GET` | `/api/bookmarks` | List bookmarks |
| `POST` | `/api/bookmarks` | Create bookmark |
| `GET` | `/api/bookmarks/:id` | Get bookmark |
| `PUT` | `/api/bookmarks/:id` | Update bookmark |
| `DELETE` | `/api/bookmarks/:id` | Delete bookmark |

### Run the app

```bash
flutter run
```

The app targets `http://localhost:8080` for API calls. Log in with any username and password — the backend accepts anything during development.

## 🔥 Firebase Setup

Firebase is pre-configured for Crashlytics and Analytics. To connect your own Firebase project:

1. Create a project in the [Firebase Console](https://console.firebase.google.com/)
2. Install the FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

3. Configure Firebase for your platforms:

```bash
flutterfire configure
```

This auto-generates `lib/firebase_options.dart` with your project credentials. The existing file contains placeholder values — replace it with the generated output.

4. Drop platform config files into your project:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

Firebase is initialized in `lib/main.dart` with Crashlytics fatal error reporting wired up for both Flutter and platform-level errors.

## 🏷 Flavors & Environment

The project supports three flavors via `--dart-define`:

| Flavor | Android app ID | Description |
|--------|---------------|-------------|
| `dev` | `com.lucistudio.flutter_starter_template.dev` | Development build, local API |
| `staging` | `com.lucistudio.flutter_starter_template.staging` | Pre-production testing |
| `prod` | `com.lucistudio.flutter_starter_template` | Production release |

Environment-specific config lives in `env/{dev,staging,prod}.json`. Build with:

```bash
fvm flutter run --flavor dev --dart-define-from-file=env/dev.json
fvm flutter run --flavor staging --dart-define-from-file=env/staging.json
fvm flutter run --flavor prod --dart-define-from-file=env/prod.json
```

The `EnvConfig` singleton (`lib/core/config/env_config.dart`) reads these at runtime via `String.fromEnvironment`, providing typed accessors for the API base URL, Firebase project IDs, and flavor name.

## 🔗 Deep Linking

The app supports Universal Links (iOS) and App Links (Android). A `DeepLinkState` holder stores the platform-provided URI through splash and auth, replaying it once the session is restored or the user signs in.

**Configured files:**
- `android/app/src/main/AndroidManifest.xml` — App Links intent filter
- `ios/Runner/Info.plist` — `FlutterDeepLinkingEnabled`
- `ios/Runner/Runner*.entitlements` — `applinks:` associated domains

**To enable:** Replace `yourdomain.com` with your actual domain in all six files and host the verification files on your server:

**`https://yourdomain.com/.well-known/apple-app-site-association`:**
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

**`https://yourdomain.com/.well-known/assetlinks.json`:**
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

## 🔧 Reusable Core Widgets

All shared UI components live in `lib/core/widgets/`:

| Widget | Description |
|--------|-------------|
| `AppScaffold` | App bar, dark/light-aware background, optional connectivity banner |
| `AppButton` | Themed button with loading state, expand, and icon support |
| `AppTextField` | Text field with label, prefix icon, validation, autofill hints |
| `AppCarousel` | Carousel slider wrapper with auto-play and dot indicators |
| `AppLinkPreview` | Rich link preview card (image, title, description) via `flutter_link_previewer` |
| `AppAnimatedText` | Typewriter and fade text animations via `animated_text_kit` |
| `AppLoading` | Centered loading spinner |
| `AppEmptyView` | Empty state with icon and message |
| `AppErrorView` | Error state with icon, message, and retry action |

## 📤 Share

Bookmarks can be shared via the system share sheet. `ShareService` wraps `share_plus` with `SharePlus.share()` — see `lib/core/share/share_service.dart`. The share button on the bookmark detail screen (`bookmark_detail_widgets.dart`) and list swipe action (`bookmarks_list_widgets.dart`) both delegate to it.

## 🧱 Tech Stack

| Category | Package |
|----------|---------|
| State management | flutter_bloc (Cubit) |
| Routing | go_router + go_router_builder |
| DI | get_it + injectable |
| Networking | Dio + Retrofit |
| Code generation | build_runner, freezed, json_serializable, retrofit_generator, injectable_generator, go_router_builder, flutter_gen_runner, objectbox_generator, build_verify |
| Local database | ObjectBox (`objectbox`, `objectbox_flutter_libs`) |
| Secure storage | flutter_secure_storage |
| Auth | JWT (access + refresh) |
| Theming | Material 3 + Google Fonts (Inter) + `flex_color_scheme` |
| i18n | flutter_localizations + intl |
| Icons | cupertino_icons |
| Assets | flutter_svg, flutter_gen_runner |
| Carousel | `carousel_slider` |
| Notifications | flutter_local_notifications |
| Firebase | firebase_core, firebase_crashlytics, firebase_analytics, firebase_messaging |
| Animations | flutter_animate, `animated_text_kit` |
| Haptics | HapticFeedback (Flutter Services) |
| Connectivity | connectivity_plus |
| Storage | path_provider, shared_preferences |
| Device info | package_info_plus |
| URL launching | url_launcher |
| Share | share_plus |
| Link preview | flutter_link_previewer |
| UUID | uuid |
| Splash screen | splashscreen |
| Testing | `mocktail`, `bloc_test` |
| Backend | Go + chi/v5 + golang-jwt/v5 + cors |

## 📝 Code Generation

This project relies heavily on code generation. Run after any model, route, or DI change:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

Generated files are git-tracked for convenience (something to consider if your team prefers otherwise).

## 🤖 AI & Agent Tooling

This project is optimized for AI-assisted development with Command Code, featuring pre-configured rules, MCP tools, taste preferences, and playbook skills.

### ⚙️ Version Pinning with FVM
Flutter and Dart SDK versions are pinned via [FVM](https://fvm.app/) in `.fvmrc`. Always prefix Flutter/Dart commands with `fvm`:
```bash
fvm flutter <command>
fvm dart <command>
```

### ✨ Command Code — Taste & Plans
Learned project preferences are stored in `.commandcode/taste/` and automatically guide AI agents to follow project conventions:
- **Flutter Packages** — package selection preferences
- **Architecture** — layered architecture, feature-slice conventions
- **Backend** — Go with go-chi router
- **Flutter Setup** — l10n, light/dark theming, flavors with `--dart-define`
- **Testing** — shared mock/fake extraction into reusable test helpers

Architectural plans and design documents are maintained in `.commandcode/plans/`.

### 🧩 Dart MCP Server
A project-scoped Dart/Flutter MCP server is configured in `.mcp.json`. It runs via `fvm dart mcp-server` and provides agents with tools for static analysis, code formatting, package management, test execution, and runtime diagnostics.

### 📝 AI Rules & Context
Custom instructions help AI tools understand coding guidelines, architecture, and project rules:
- **Command Code**: Taste preferences in `.commandcode/taste/`, plans in `.commandcode/plans/`
- **Claude Code**: Guidelines in `CLAUDE.md`
- **Antigravity**: Custom guidelines in `.antigravityrules`

### 🛠 Agent Skills
Official task-playbooks from `flutter/skills` and `dart-lang/skills` are vendored under `.agents/skills/` and pinned in `skills-lock.json`. These encode standardized workflows for common development tasks:

**Flutter skills:**
- `flutter-setup-declarative-routing` — go_router with typed routes
- `flutter-implement-json-serialization` — fromJson/toJson model classes
- `flutter-add-widget-test` — WidgetTester component tests
- `flutter-add-widget-preview` — interactive widget previews
- `flutter-add-integration-test` — Flutter Driver / integration_test
- `flutter-apply-architecture-best-practices` — layered UI/Logic/Data
- `flutter-build-responsive-layout` — LayoutBuilder, MediaQuery
- `flutter-fix-layout-issues` — overflow, unbounded constraints
- `flutter-setup-localization` — intl + ARB setup
- `flutter-use-http-package` — REST API integration

**Dart skills:**
- `dart-add-unit-test` — package:test unit tests
- `dart-run-static-analysis` — dart analyze + dart fix
- `dart-fix-runtime-errors` — stack trace diagnostics
- `dart-generate-test-mocks` — mockito + build_runner
- `dart-collect-coverage` — LCOV coverage reports
- `dart-build-cli-app` — CLI entrypoints and exit codes
- `dart-resolve-package-conflicts` — pub get conflict resolution
- `dart-migrate-to-checks-package` — matcher → checks migration
- `dart-use-pattern-matching` — switch expressions and pattern matching

Agents auto-discover and execute these playbooks to ensure consistent implementation patterns.

## 📄 License

MIT — see [LICENSE](LICENSE) for details.

---

Made with ❤️ by [Luci](https://lucistudio.com)

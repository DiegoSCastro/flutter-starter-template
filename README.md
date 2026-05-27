# Flutter Starter Template

A production-ready Flutter starter template built by [Luci](https://lucistudio.com). Batteries included: Clean Architecture, offline-first sync, JWT auth, Firebase, i18n, theming, and a companion Go backend — everything you need to ship fast.

## ✨ Features

- **Clean Architecture** — data, domain, and presentation layers with dependency inversion
- **BLoC state management** — Cubit pattern with freezed sealed state unions
- **Offline-first bookmarks** — local ObjectBox writes, bidirectional sync on reconnect
- **JWT authentication** — access + refresh tokens, auto-refresh interceptor, secure storage
- **Declarative routing** — go_router with typed routes, auth redirect guards
- **Dark / light / system theming** — Material 3, ColorScheme.fromSeed, Google Fonts (Inter)
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

- Flutter SDK ≥ 3.27 (managed via [FVM](https://fvm.app/) — see `.fvm/fvm_config.json`)
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

## 🧱 Tech Stack

| Category | Package |
|----------|---------|
| State management | flutter_bloc (Cubit) |
| Routing | go_router + go_router_builder |
| DI | get_it + injectable |
| Networking | Dio + Retrofit |
| Code generation | freezed, json_serializable, retrofit_generator, injectable_generator, go_router_builder, flutter_gen_runner, objectbox_generator |
| Local database | ObjectBox |
| Secure storage | flutter_secure_storage |
| Auth | JWT (access + refresh) |
| Theming | Material 3 + Google Fonts (Inter) |
| i18n | flutter_localizations + intl |
| Icons | cupertino_icons |
| Assets | flutter_svg, flutter_gen_runner |
| Notifications | flutter_local_notifications |
| Firebase | firebase_core, firebase_crashlytics, firebase_analytics, firebase_messaging |
| Animations | flutter_animate |
| Haptics | HapticFeedback (Flutter Services) |
| Connectivity | connectivity_plus |
| Storage | path_provider, shared_preferences |
| Device info | package_info_plus |
| URL launching | url_launcher |
| UUID | uuid |
| Splash screen | splashscreen |
| Backend | Go + chi/v5 + golang-jwt/v5 |

## 📝 Code Generation

This project relies heavily on code generation. Run after any model, route, or DI change:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files are git-tracked for convenience (something to consider if your team prefers otherwise).

## 📄 License

MIT — see [LICENSE](LICENSE) for details.

---

Made with ❤️ by [Luci](https://lucistudio.com)

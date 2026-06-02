# Core (`core`)

This directory contains reusable, cross-feature code that is shared across the entire application. 

In our feature-first Clean Architecture approach, the `core` directory holds the foundational, app-owned infrastructure that any feature can depend on. However, **code inside `core/` must never depend on code inside `features/`**.

Most reusable, third-party-backed infrastructure has been extracted into
workspace packages under `packages/` (see the table below). What remains in
`lib/core/` is infrastructure that stays coupled to the assembled app —
the DI composition root, the ObjectBox store, and Firebase bootstrap.

## Directory Structure

Here is a breakdown of the subdirectories found in `core/`:

- **`data/database/`**: The app's ObjectBox wrapper and its generated store binding (`object_box.dart`).
- **`di/`**: Dependency Injection setup (`get_it` + `injectable`) that composes the app graph, wiring together services from the workspace packages and the feature modules.
- **`extensions/`**: App-specific convenience extensions used across features.
- **`platform/firebase/`**: App bootstrap for Firebase services (`FirebaseService` — initialization, Crashlytics handlers, background messaging).

## Where the rest of `core` went

Reusable, non-visual infrastructure now lives in versioned workspace packages,
consumed through their entry points (e.g. `package:core_network/core_network.dart`):

| Concern | Package |
|---|---|
| Architecture primitives (`Failure`, `Result`, `UseCase`) | `core_domain` |
| Networking (`Dio`, `Retrofit`, interceptors) | `core_network` |
| Analytics + route observer | `core_analytics` |
| Env + Remote Config | `core_config` |
| Secure storage + preferences | `core_storage` |
| Media, picker, permissions, notifications, share | `core_platform` |
| Theme state (`ThemeBloc`) | `core_theme` |
| Design system — theming, widgets, layout, animation | `app_ui` |

> [!NOTE]
> The design system (theming, reusable generic widgets, layout primitives, and
> animations) lives in the `app_ui` package, not here. `core/` is for non-visual,
> app-coupled infrastructure.

## Golden Rule

> [!IMPORTANT]
> The dependency graph must flow inwards. Features can import from `core`, but `core` **cannot** import from `features`. If a piece of code in `core` requires knowledge of a specific feature, it likely belongs in that feature instead.

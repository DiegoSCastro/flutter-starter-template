# Core (`core`)

This directory contains reusable, cross-feature code that is shared across the entire application. 

In our feature-first Clean Architecture approach, the `core` directory holds the foundational layers and utilities that any feature can depend on. However, **code inside `core/` must never depend on code inside `features/`**.

## Directory Structure

Here is a breakdown of the typical subdirectories found in `core/`:

- **`analytics/`**: Centralized services for logging events, screen views, and user properties (e.g., Firebase Analytics wrapper).
- **`config/`**: App-wide configurations, environment variables, feature flags, and constants.
- **`di/`**: Dependency Injection setup (e.g., `get_it` or `injectable` configurations) for registering all core services, repositories, and BLoCs.
- **`domain/`**: Architecture-level domain primitives shared by feature domains, such as `Failure`, `Result<T>`, and `UseCase`.
- **`data/`**: Reusable data-layer infrastructure, such as networking clients, interceptors, API configuration, and data-source helpers.
- **`extensions/`**: Generic extensions used across the app (e.g., `build_context_extensions.dart`, `future_extensions.dart`).
- **`layout/`**: Responsive layout primitives such as breakpoints.
- **`platform/`**: App-wide platform and plugin integrations, such as Firebase initialization, media picking/playback, push/local notifications, OS permissions, and sharing.

> [!NOTE]
> The design system — global theming (`theme/`), reusable generic widgets
> (`widgets/`), and animation primitives (`animation/`) — lives in `lib/ui/`,
> not here. `core/` is for non-visual infrastructure.

## Golden Rule

> [!IMPORTANT]
> The dependency graph must flow inwards. Features can import from `core`, but `core` **cannot** import from `features`. If a piece of code in `core` requires knowledge of a specific feature, it likely belongs in that feature instead.

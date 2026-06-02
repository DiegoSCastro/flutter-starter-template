# Core (`core`)

This directory contains reusable, cross-feature code that is shared across the entire application. 

In our feature-first Clean Architecture approach, the `core` directory holds the foundational layers and utilities that any feature can depend on. However, **code inside `core/` must never depend on code inside `features/`**.

## Directory Structure

Here is a breakdown of the typical subdirectories found in `core/`:

- **`analytics/`**: Centralized services for logging events, screen views, and user properties (e.g., Firebase Analytics wrapper).
- **`config/`**: App-wide configurations, environment variables, feature flags, and constants.
- **`di/`**: Dependency Injection setup (e.g., `get_it` or `injectable` configurations) for registering all core services, repositories, and BLoCs.
- **`domain/`**: Architecture-level domain primitives shared by feature domains, such as `Failure`, `Result<T>`, and `UseCase`.
- **`extensions/`**: Generic extensions used across the app (e.g., `build_context_extensions.dart`, `future_extensions.dart`).
- **`layout/`**: Responsive layout primitives such as breakpoints.
- **`media/`**: Camera, image-picker, and video-player services.
- **`network/`**: Base networking clients (e.g., `Dio` or `http`), interceptors, API configuration, and network connectivity checkers.
- **`notifications/`**: Push notifications logic, local notifications configuration, and handling notification taps.
- **`permissions/`**: Centralized handling for requesting and checking OS permissions (camera, location, notifications).
- **`share/`**: Cross-platform sharing utilities (e.g., sharing text, images, or deep links via `share_plus`).

> [!NOTE]
> The design system — global theming (`theme/`), reusable generic widgets
> (`widgets/`), and animation primitives (`animation/`) — lives in `lib/ui/`,
> not here. `core/` is for non-visual infrastructure.

## Golden Rule

> [!IMPORTANT]
> The dependency graph must flow inwards. Features can import from `core`, but `core` **cannot** import from `features`. If a piece of code in `core` requires knowledge of a specific feature, it likely belongs in that feature instead.

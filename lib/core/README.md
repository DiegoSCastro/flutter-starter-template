# Core (`core`)

This directory contains reusable, cross-feature code that is shared across the entire application. 

In our feature-first Clean Architecture approach, the `core` directory holds the foundational layers and utilities that any feature can depend on. However, **code inside `core/` must never depend on code inside `features/`**.

## Directory Structure

Here is a breakdown of the typical subdirectories found in `core/`:

- **`analytics/`**: Centralized services for logging events, screen views, and user properties (e.g., Firebase Analytics wrapper).
- **`animation/`**: Reusable animation controllers, implicitly animated widgets, and transition utilities.
- **`config/`**: App-wide configurations, environment variables, feature flags, and constants.
- **`di/`**: Dependency Injection setup (e.g., `get_it` or `injectable` configurations) for registering all core services, repositories, and BLoCs/Cubits.
- **`error/`**: Global error handling, custom exception definitions (`Failure`, `Exception`), and error mappers.
- **`network/`**: Base networking clients (e.g., `Dio` or `http`), interceptors, API configuration, and network connectivity checkers.
- **`notifications/`**: Push notifications logic, local notifications configuration, and handling notification taps.
- **`permissions/`**: Centralized handling for requesting and checking OS permissions (camera, location, notifications).
- **`share/`**: Cross-platform sharing utilities (e.g., sharing text, images, or deep links via `share_plus`).
- **`theme/`**: Global UI theming, including color palettes, typography, theme data, and theme switching logic (`ThemeCubit`).
- **`usecases/`**: Base classes for Clean Architecture Use Cases (e.g., `UseCase<Type, Params>`).
- **`utils/`**: Generic helper functions, extensions (e.g., `build_context_extensions.dart`), formatters, and small utilities that don't fit into a specific domain.
- **`widgets/`**: Reusable UI components that are entirely generic and not tied to any specific feature (e.g., custom buttons, generic loading spinners, base dialogs).

## Golden Rule

> [!IMPORTANT]
> The dependency graph must flow inwards. Features can import from `core`, but `core` **cannot** import from `features`. If a piece of code in `core` requires knowledge of a specific feature, it likely belongs in that feature instead.

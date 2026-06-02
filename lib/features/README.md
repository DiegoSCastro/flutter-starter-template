# Features

This directory contains the distinct feature modules of the application, structured using a feature-first approach combined with Clean Architecture.

Each folder in this directory represents an independent, cohesive feature of the app (e.g., `auth`, `home`, `profile`, `bookmarks`, `splash`).

## Clean Architecture Structure

Inside each feature directory, you will typically find the following three layers:

### 1. `domain/`
The innermost layer containing the core business logic of the feature. It should be independent of any external packages, frameworks, or UI code.
- **Entities:** Immutable domain models representing core business objects (typically utilizing `freezed`).
- **Repositories (Interfaces):** Abstract contracts/interfaces defining how data is accessed.
- **Use Cases / Services:** Classes containing the business rules that orchestrate repositories.

### 2. `data/`
The outermost layer responsible for data retrieval and persistence. This layer implements the repository interfaces defined in the domain layer.
- **Repositories (Implementations):** Concrete classes that implement domain interfaces.
- **Data Sources:** Classes that handle communication with external APIs, local databases, Firebase, or shared preferences.
- **DTOs (Data Transfer Objects):** Models specifically used for parsing external data formats (like JSON).

### 3. `presentation/`
The UI layer responsible for displaying information to the user and capturing user input.
- **State Management:** BLoCs that manage the state of the UI and interact with domain services.
- **Screens / Pages:** Full-screen widgets representing a complete view.
- **Widgets:** Smaller, reusable UI components specific to this feature.

## Best Practices

- **Feature Independence:** Features should be as isolated as possible. As a default, a feature must **not** import another feature's `presentation` layer — shared *state* is read through a contract in `lib/shared/` instead. The one deliberate exception is a *capability* (a self-contained presentation object one feature surfaces inside another); while only a single consumer exists, importing it directly is allowed.
- **Shared Code:** Pick the destination by what kind of thing it is:
  - *Business* vocabulary used by 2+ features (e.g. the session, shared entities) → `lib/shared/`, on the **rule of three** (promote only when ≥2 features depend on it today).
  - *Cross-cutting, non-visual* infrastructure → `lib/core/` (app-coupled) or a `packages/core_*` workspace package (reusable).
  - *Generic visual* building blocks → the `app_ui` package.
- **Immutability:** Use immutable models and `Freezed` unions for state management and domain entities.
- **Dependency Injection:** Dependencies are injected using `get_it` + `injectable` (composition root in `lib/core/di/`).

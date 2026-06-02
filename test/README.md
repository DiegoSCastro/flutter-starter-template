# Tests

This directory contains the automated tests for the Flutter Starter Template.

The testing strategy emphasizes unit tests for logic and widget tests for UI components, following the feature-first Clean Architecture pattern used in the `lib` directory.

## Directory Structure

This `test/` directory holds **root app tests only** and mirrors the app's
`lib/` structure. Reusable infrastructure now lives in workspace packages, and
each package owns its tests under `packages/<name>/test` — so there is no
`test/core/` here; those suites moved into the relevant `core_*` / `app_ui`
packages.

- `features/`: Tests for the app's features, organized by data, domain, and presentation layers.
- `test_utils/`: Root-only test helpers.
  - `mocks.dart`: Hand-written `mocktail` mocks/fakes for the app's repositories, use cases, and services (e.g. `MockSignIn`, `FakeSession`).
  - `fixtures.dart`: Reusable test data used across multiple tests.
- `test_utils.dart`: Barrel file. Re-exports `package:test_utils/test_utils.dart` (the shared `mocktail` export plus cross-package mocks/fakes) alongside the local `mocks.dart` and `fixtures.dart`.
- `widget_test.dart`: An integration-style widget test that exercises the full app startup and sign-in flow.

## Mocking Dependencies

This project uses [`mocktail`](https://pub.dev/packages/mocktail) for mocking
dependencies. `mocktail` is runtime-based, so mocks are **written by hand** and
require **no code generation** — declare them directly:

```dart
class MockAuthRepository extends Mock implements AuthRepository {}
```

The `Mock`/`Fake` base classes come from `package:test_utils/test_utils.dart`,
re-exported through the `test_utils.dart` barrel.

## Running Tests

Since this project pins Flutter to a specific version via FVM, always run tests using `fvm flutter`.

Run all tests:
```bash
fvm flutter test
```

Run tests in a specific file:
```bash
fvm flutter test test/widget_test.dart
```

Run a specific test by name (substring match):
```bash
fvm flutter test --name "signs in and lands on home screen"
```

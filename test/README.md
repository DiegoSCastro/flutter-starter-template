# Tests

This directory contains the automated tests for the Flutter Starter Template.

The testing strategy emphasizes unit tests for logic and widget tests for UI components, following the feature-first Clean Architecture pattern used in the `lib` directory.

## Directory Structure

The `test/` directory mirrors the `lib/` directory structure:

- `core/`: Tests for reusable cross-feature code (e.g., core utilities, networking, local storage, theming).
- `features/`: Tests for specific features, organized by data, domain, and presentation layers.
- `test_utils/`: Contains shared test utilities, generated mocks, and reusable test fixtures.
  - `mocks.dart`: Generated `mocktail` mocks for repositories, services, and other dependencies.
  - `fixtures.dart`: Reusable test data and mock objects used across multiple tests.
- `test_utils.dart`: Barrel file exporting mocks and fixtures for easy importing in your tests.
- `widget_test.dart`: An integration-style widget test that exercises the full app startup and sign-in flow.

## Mocking Dependencies

This project uses [`mocktail`](https://pub.dev/packages/mocktail) for mocking dependencies. 

To generate or update mocks (if using code generation for mocks), run the build runner:
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

*(Note: If you write mocks manually using `class MockMyClass extends Mock implements MyClass {}`, no code generation is required.)*

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

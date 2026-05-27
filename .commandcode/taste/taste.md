# Flutter Packages
See [flutter-packages/taste.md](flutter-packages/taste.md)
# Architecture
- Structure the project using clean architecture layers (data, domain, presentation). Confidence: 0.70
- Use BLoC pattern for view model layer. Confidence: 0.70
- Use freezed for cubit/bloc state classes. Confidence: 0.70
- Implement offline-first architecture pattern. Confidence: 0.65
- Implement JWT authentication. Confidence: 0.65

# Backend
- Use Go with go-chi router for backend server. Confidence: 0.65

# Flutter Setup
- Set up l10n (localization) for the app. Confidence: 0.70
- Support light and dark mode theming. Confidence: 0.70
- Follow Flutter.dev AI rules and agent skills guidelines. Confidence: 0.65
- Use Flutter flavors with --dart-define for environment configuration. Confidence: 0.50

# Testing
- Extract shared mock/fake classes and test utilities (e.g., MockSignIn, FakeBookmarkInput, registerFallbackValue calls) into reusable test helper files to avoid repeating setup across test files. Confidence: 0.70

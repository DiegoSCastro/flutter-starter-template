# Isolate Service Infrastructure via squadron ^7.4.3

## Overview

Add a reusable isolate service abstraction using the `squadron` package. Any existing or future service (sync, token refresh, image processing, etc.) can adopt the pattern by extending a base class and registering with the manager. Communication uses a command/response pattern — the main isolate sends typed commands, the background isolate processes them and returns typed responses.

## Files to Create

### 1. `lib/core/isolate/isolate_service.dart`
- Abstract base class extending `SqdrnService` (the squadron base for isolate-hosted services)
- Provides lifecycle hooks: `initialize()`, `dispose()`
- Concrete services override these to set up dependencies inside the isolate

### 2. `lib/core/isolate/isolate_service_manager.dart`
- Wraps `SqdrnWorker` instances (the squadron-generated client proxy)
- Lifecycle methods: `start()`, `stop()`, `restart()`
- Exposes workers for command dispatch
- Status stream (`IsolateStatus.idle | starting | running | error | stopped`)
- Single-flight pattern for start/stop (like existing `BookmarksSyncService._inflight`)

### 3. `lib/core/isolate/isolate_module.dart`
- `@module` abstract class registering isolate infrastructure into get_it
- Provides the `IsolateServiceManager` as a `@lazySingleton`

### 4. `lib/core/isolate/isolate_status.dart`
- Enum: `IsolateStatus { idle, starting, running, error, stopped }`

### 5. `lib/core/isolate/services/ping_isolate_service.dart`
- Smoke-test service: extends `IsolateService`, exposes `ping(String message)` returning `pong: $message`
- Used to verify the full isolate lifecycle works end-to-end

### 6. `lib/core/isolate/services/ping_isolate_service.worker.dart`
- Squadron-generated worker (produced by `build_runner`)

## Files to Modify

### 7. `pubspec.yaml`
- Add `squadron: ^7.4.3` to dependencies

### 8. `lib/core/di/injection.dart`
- Expose `startIsolateServices()` helper that retrieves the manager and calls `start()` on registered workers

### 9. `lib/main.dart`
- Call `startIsolateServices()` after Firebase init

## Architecture

```
┌─ Main Isolate ──────────────────────────────────┐
│                                                  │
│  IsolateServiceManager                           │
│  ┌──────────────────┐  ┌──────────────────┐      │
│  │ PingWorker       │  │ (future worker)  │ ...  │
│  │ (SqdrnWorker)    │  │ (SqdrnWorker)    │      │
│  └───────┬──────────┘  └───────┬──────────┘      │
│          │ commands             │                 │
└──────────┼─────────────────────┼─────────────────┘
           │                     │
    ┌──────▼──────────┐  ┌──────▼──────────┐
    │ PingService     │  │ OtherService    │  ... 
    │ (SqdrnService)  │  │ (SqdrnService)  │
    └─────────────────┘  └─────────────────┘
    Background Isolate    Background Isolate
```

## Key Design Decisions

1. **Command pattern**: Services expose methods that accept command objects and return response objects. Squadron serializes arguments and return values across the isolate boundary automatically.

2. **Manager owns lifecycle**: The `IsolateServiceManager` handles start, stop, and error monitoring for all registered worker instances. Services don't manage their own isolate directly.

3. **DI-friendly**: The manager is a `@lazySingleton`. Workers are created via the manager's `start(worker)` method with squadron's generated `$PingServiceWorker` classes.

4. **Error handling**: Worker failures emit `IsolateStatus.error` through a stream. The `IsolateServiceManager` can apply optional auto-restart.

5. **Pattern alignment**: Follows existing project conventions — `@lazySingleton` annotations, `@module` for external dependencies, single-flight concurrency pattern.

## Verification

1. `flutter pub get` resolves squadron ^7.4.3
2. `dart run build_runner build` generates the PingService worker
3. `dart analyze` passes with no errors
4. `flutter test` passes all existing tests

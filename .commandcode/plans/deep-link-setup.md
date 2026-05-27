# Deep Link Setup — Implementation Plan

## Summary

Configure Universal Links (iOS) / App Links (Android) for the Flutter bookmarks app. Replace the hardcoded `initialLocation: '/splash'` with a redirect-based approach that preserves deep link targets through the auth flow. Add native platform intent filters and associated domain configurations.

**App IDs:**
- Android: `com.lucistudio.flutter_starter_template` (+ `.dev`, `.staging` flavors)
- iOS: `com.luci-studio.flutterStarterTemplate`
- Placeholder domain: `yourdomain.com` (replace with real domain later)

---

## Approach

The current `GoRouter` uses `initialLocation: '/splash'` and the `SplashScreen` unconditionally navigates to `/` or `/login`, discarding the platform-provided deep link URI. 

**Fix**: Remove `initialLocation`, add a `DeepLinkState` holder, and let the redirect capture + restore deep link targets through the auth lifecycle.

### Redirect flow

| Scenario | Redirect behavior |
|---|---|
| Cold start, deep link, has session | Store deep link → splash → `/` (post-restore) → restore pending deep link |
| Cold start, deep link, no session | Store deep link → splash → `/login` → after login → restore pending deep link |
| Normal cold start, has session | Store `/` → splash → `/` (post-restore) → restore `/` |
| Normal cold start, no session | Store `/` → splash → `/login` → after login → restore `/` |
| Warm start (backgrounded), deep link | Direct navigation if authenticated; store + redirect to login if not |

---

## Files to Change

### 1. `lib/app/router.dart` — Rewrite redirect logic

**Current state**: `initialLocation: '/splash'`, simple auth redirect.
**Target state**: No fixed initial location, deep-link-aware redirect.

**Changes**:
- Remove `initialLocation` parameter from `GoRouter(...)`
- Add `DeepLinkState` class to router.dart:
  ```dart
  class DeepLinkState {
    String? pendingRedirect;
    bool splashCompleted = false;
  }
  ```
- Add module-level instance (singleton access for SplashScreen):
  ```dart
  DeepLinkState? _deepLinkStateInstance;
  DeepLinkState get deepLinkState => _deepLinkStateInstance!;
  ```
- Rewrite `buildRouter` → `buildRouterWithDeepLink` returning both router and state:
  ```dart
  ({GoRouter router, DeepLinkState deepLink}) buildRouterWithDeepLink(
    AuthCubit cubit,
  ) {
    final deepLink = DeepLinkState();
    _deepLinkStateInstance = deepLink;
    final router = GoRouter(
      // REMOVED: initialLocation — GoRouter resolves from platform deep link URI
      routes: $appRoutes,
      refreshListenable: _CubitListenable(cubit.stream),
      redirect: (context, state) {
        final location = state.matchedLocation;
        final auth = cubit.state;

        // Phase 1: Before splash completes — intercept everything
        if (auth is AuthInitial && !deepLink.splashCompleted) {
          if (location == '/splash') return null; // wait
          deepLink.pendingRedirect = state.uri.toString();
          return '/splash';
        }

        // Phase 2: Unauthenticated
        if (auth is AuthInitial || auth is AuthFailure) {
          if (location == '/login') return null;
          deepLink.pendingRedirect ??= state.uri.toString();
          return '/login';
        }

        // Phase 3: Authenticated
        if (auth is AuthAuthenticated) {
          if (location == '/splash' || location == '/login') {
            final target = deepLink.pendingRedirect;
            deepLink.pendingRedirect = null;
            return target ?? '/';
          }
          return null; // allow direct navigation
        }

        // AuthSubmitting — don't interfere
        return null;
      },
    );
    return (router: router, deepLink: deepLink);
  }
  ```

---

### 2. `lib/app/app.dart` — Store DeepLinkState, pass to router

**Current state**:
```dart
_router = buildRouter(_authCubit);
```

**Target state**:
```dart
final result = buildRouterWithDeepLink(_authCubit);
_router = result.router;
```

Add `late final DeepLinkState _deepLinkState;` field (unused directly, but ensures the instance exists).

---

### 3. `lib/features/splash/presentation/screens/splash_screen.dart` — Simplify, mark completion

**Current state**:
```dart
final next = cubit.state is AuthAuthenticated ? '/' : '/login';
context.go(next);
```

**Target state**:
```dart
deepLinkState.splashCompleted = true;
context.go('/');
```

Add import:
```dart
import '../../../../app/router.dart';
```

Remove the auth-state check. The redirect handles routing post-splash. The splash screen simply marks completion and navigates to `/`.

---

### 4. `lib/features/auth/presentation/screens/login_screen.dart` — No changes needed

The redirect handles post-login navigation automatically. When `AuthAuthenticated` emits at `/login`, the redirect consumes `pendingRedirect` and navigates to the stored deep link (or `/`).

---

### 5. `android/app/src/main/AndroidManifest.xml` — Add intent filter

Add a second `<intent-filter>` inside the existing `<activity>` block, **after** the launcher intent-filter:

```xml
<!-- Deep Links (App Links) -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="http" android:host="yourdomain.com" />
    <data android:scheme="https" />
</intent-filter>
```

---

### 6. `ios/Runner/Info.plist` — Enable Flutter deep link handling

Add before the closing `</dict>`:

```xml
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

---

### 7. iOS Entitlements — Associated Domains

Add to all three entitlement files (`Runner.entitlements`, `RunnerDebug.entitlements`, `RunnerRelease.entitlements`):

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:yourdomain.com</string>
</array>
```

Place after the existing `<dict>` opening tag, before the `aps-environment` key.

---

### 8. Server Verification Files (placeholders)

These live on your web server, documented here for reference:

**`https://yourdomain.com/.well-known/apple-app-site-association`** (no `.json` extension):
```json
{
  "applinks": {
    "apps": [],
    "details": [{
      "appIDs": ["TEAM_ID.com.luci-studio.flutterStarterTemplate"],
      "paths": ["*"]
    }]
  }
}
```
Replace `TEAM_ID` with your Apple Developer Team ID.

**`https://yourdomain.com/.well-known/assetlinks.json`**:
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.lucistudio.flutter_starter_template",
    "sha256_cert_fingerprints": [
      "YOUR_RELEASE_SHA256_FINGERPRINT"
    ]
  }
}]
```
Get the SHA256 fingerprint from the Play Console (Release → Setup → App integrity → App signing key certificate).

---

## Verification

### Dart-side tests
After refactoring `buildRouter`, verify the redirect with unit tests:
- Cold start without deep link → redirects to `/splash` then `/` (authenticated) or `/login` (unauthenticated)
- Cold start with deep link `/bookmarks/abc` → stores it → after auth, navigates to `/bookmarks/abc`
- Deep link while authenticated → navigates directly
- Deep link while unauthenticated → stores it → redirects to `/login` → after login, navigates to deep link

### Android
```bash
adb shell am start -a android.intent.action.VIEW \
  -c android.intent.category.BROWSABLE \
  -d "https://yourdomain.com/bookmarks/abc" \
  com.lucistudio.flutter_starter_template
```

### iOS Simulator
```bash
xcrun simctl openurl booted "https://yourdomain.com/bookmarks/abc"
```

---

## Key Design Decisions

1. **Module-level `DeepLinkState` singleton** — pragmatic access pattern that works with go_router_builder's generated route classes (which don't support custom constructor args for `SplashScreen`).
2. **Splash screen always navigates to `/`** — the redirect owns routing decisions. The splash screen's only responsibility is session restore + minimum display time.
3. **No `app_links` or third-party plugin** — Flutter's built-in deep link support (`FlutterDeepLinkingEnabled`) + `go_router` handles everything.
4. **`_pendingRedirect` uses `??=`** — the first deep link captured is preserved even if the user navigates away before re-authentication.
5. **No changes to `AuthCubit` or `AuthState`** — the redirect distinguishes restore-before-attempted from restore-failed via the `splashCompleted` flag, keeping cubit internals untouched.

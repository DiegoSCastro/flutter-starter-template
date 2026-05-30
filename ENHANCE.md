# ENHANCE.md — Improvement & Fix Backlog

A prioritized, actionable review of this codebase. Each item lists **where**
(file:line), **what's wrong**, and **how to fix it**.

> **Baseline at time of review:** `fvm flutter analyze` → *No issues found*.
> Full suite → *275 tests pass*. So nothing here is a lint or a failing test —
> these are **design, robustness, offline-first, security, and DX** issues that
> static analysis cannot catch.

## How to read this

| Severity | Meaning |
|---|---|
| 🔴 **Critical** | User-visible correctness bug or data loss; fix before shipping. |
| 🟠 **High** | Breaks a headline feature (offline-first) or a security boundary. |
| 🟡 **Medium** | Reliability / build-reproducibility / dev-experience gaps. |
| 🟢 **Low** | Polish, hardening, docs, test depth. |

---

## ✅ Implementation status (last updated 2026-05-30)

Most of this backlog has now been implemented. Verified after the changes:
`flutter analyze` clean · **289 tests pass** (was 275; +14 new) · `dart format`
clean · Go backend `go build` OK.

| # | Item | Status |
|---|------|--------|
| 1 | Offline cold-start force-logout | ✅ Fixed |
| 2 | Sync poison-pill + media re-upload | ✅ Fixed |
| 3 | Retry interceptor idempotency | ✅ Fixed |
| 4 | Android cleartext for dev backend | ✅ Fixed |
| 5 | Unpinned `any` dependencies | ✅ Fixed |
| 6 | Crashlytics not silenced in debug | ✅ Fixed |
| 7 | Fresh clone doesn't compile (Firebase) | ✅ Fixed (committed a non-real placeholder `firebase_options.dart`) |
| 8 | Corrupt session JSON guard | ✅ Fixed |
| 9 | `flutter_secure_storage` default options | ✅ Fixed (iOS `first_unlock_this_device` + Android encrypted) |
| 10 | Stale `load()` doc comment | ✅ Fixed |
| 11 | Backend upload size cap | ✅ Fixed (content-type/extension validation still TODO) |
| 12 | Coverage floor / golden+integration in CI | ⬜ Ongoing |
| 13 | Placeholder App Link host | ⬜ Template placeholder (left intentionally) |

Each fixed item below retains its original description for context. See git diff
for the concrete changes and the new tests under
`test/features/auth/data/network/token_refresher_test.dart` and the extended
sync/retry suites.

---

## 🔴 / 🟠 Critical & High

### 1. 🔴 Launching offline force-logs-out the user and **wipes their tokens**
**Where:** `lib/features/auth/data/repositories/auth_repository_impl.dart:116-131`
combined with `lib/features/auth/data/network/token_refresher.dart:26-49`.

`restoreSession()` always performs a network token refresh on cold start. The
refresher treats **any** `DioException` — including `connectionError`,
`connectionTimeout`, `receiveTimeout` (i.e. *offline*) — as a dead session and
calls `_local.clearSession()`. `restoreSession` then also clears and returns
`NoSessionFailure`.

```dart
// token_refresher.dart
} on DioException {
  await _local.clearSession();   // ← fires on a transient network blip too
  return false;
}
```

**Impact:** This directly contradicts the project's headline "offline-first"
claim. A user who opens the app on a plane / subway / flaky network is signed
out, and the stored refresh token is destroyed — they must log in again once
back online.

**Fix:** Distinguish *transport* failures from *auth* failures.
- On `connectionError` / timeouts → **keep** the session, return success
  optimistically, and let `AuthInterceptor` refresh lazily on the first 401 once
  connectivity returns.
- Only clear the session on a genuine auth rejection (HTTP 401 / server
  `invalid_refresh`).

```dart
} on DioException catch (e) {
  final transient = e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout;
  if (!transient && e.response?.statusCode == 401) {
    await _local.clearSession();
  }
  return false;
}
```
…and have `restoreSession` treat "had tokens but refresh was only *deferred*"
as an authenticated (optimistic) restore rather than `NoSessionFailure`.

---

### 2. 🟠 Bookmark sync is a **poison-pill queue** + duplicates media on retry
**Where:** `lib/features/bookmarks/data/sync/bookmarks_sync_service.dart:117-174`
(`_push`) and `:230-260` (`_uploadMediaFiles` / `_uploadSingleMedia`).

Two coupled problems:

**(a) One bad row blocks the entire queue forever.** `_push()` iterates pending
rows in a single loop. A non-404 `DioException` on any create/update (e.g. a
server `400 invalid_input`, `409 conflict`, or `500`) propagates out of the
loop, is swallowed by `_run`'s `catch`, and **every later pending row is skipped
until next sync** — which re-hits the same poison row and stops again. A single
permanently-rejected bookmark stalls all subsequent local writes indefinitely.

**(b) Re-upload duplication.** A row's `imageUrls`/`videoUrl` are only persisted
back (`_local.put(row)`) *after* the whole create/update succeeds. If the
`create`/`update` call fails *after* media uploaded, the local row still holds
the original **local file paths**, so the next sync re-uploads the same files →
orphaned/duplicate blobs on the server every retry. (Multipart requests are also
not safely retryable — see item 3 — so the first attempt may even half-succeed.)

**Fix:**
- Wrap each row in its own `try/catch` so one failure `continue`s to the next
  row instead of aborting the drain.
- Persist uploaded remote URLs back onto the row **before** the create/update
  call, so a later failure never re-uploads.
- Add a per-row failure counter / backoff (or a `failed` terminal state) so a
  poison row stops retrying forever and can be surfaced to the user.

---

### 3. 🟠 Retry interceptor retries **non-idempotent** requests
**Where:** `lib/core/network/retry_interceptor.dart:67-82`.

`_shouldRetry` returns `true` for `connectionError` and all timeout types
**regardless of HTTP method**. A `POST /api/upload` or `POST /api/bookmarks`
that times out *after the server processed it* is retried → duplicate side
effects. Worse, `POST /api/upload` sends a `MultipartFile`, whose stream is
single-use; re-dispatching the same `RequestOptions` typically fails outright.

**Fix:** Only retry idempotent methods on transport errors, e.g.

```dart
static const _idempotent = {'GET', 'HEAD', 'PUT', 'DELETE', 'OPTIONS'};
bool _methodIsRetryable(RequestOptions o) =>
    _idempotent.contains(o.method.toUpperCase());
```

Gate timeout/connection retries on `_methodIsRetryable`, or require an explicit
`options.extra['retry'] == true` opt-in for POSTs you know are safe (e.g. the
UUID-keyed bookmark create). Retryable *status codes* (429/503…) can stay as-is
since those mean "not processed."

---

## 🟡 Medium

### 4. 🟡 Android dev build can't reach the local backend (cleartext blocked)
**Where:** `android/app/src/main/AndroidManifest.xml` (no network-security
config) + `env/dev.json` (`API_BASE_URL: http://localhost:8080`).

Android API 28+ blocks cleartext HTTP by default. The dev flavor points at
plain `http://`, so a debug build throws `CLEARTEXT communication not
permitted`. (Also note: on an emulator, `localhost` is the *emulator*, not the
host — the dev URL usually needs to be `http://10.0.2.2:8080`.)

**Fix:** Add a **debug-only** `res/xml/network_security_config.xml` permitting
cleartext to `localhost` / `10.0.2.2`, reference it from a `debug/`
`AndroidManifest.xml` (`android:networkSecurityConfig`), and document the
`10.0.2.2` emulator address in `env/README.md`. Keep production cleartext-off.

### 5. 🟡 Unpinned `any` dependencies break build reproducibility
**Where:** `pubspec.yaml` — `intl: any` (line 53) and `vector_graphics: any`
(line 163).

`any` lets a transitive upgrade silently change behavior between machines/CI.
**Fix:** pin to caret ranges (`vector_graphics: ^x.y.z`; for `intl`, match the
version `flutter_localizations` resolves to). `pubspec.lock` is committed which
helps, but the manifest should still express intent.

### 6. 🟡 Crashlytics not silenced in debug builds
**Where:** `lib/core/firebase/firebase_service.dart:17-34`.

`FlutterError.onError` and `PlatformDispatcher.onError` are wired to Crashlytics
unconditionally. `PerformanceInterceptor` is correctly gated on `!env.isDev`,
but crash collection is not — so local/dev crashes pollute production
Crashlytics, and overriding `FlutterError.onError` can suppress the red-screen
dump devs rely on.

**Fix:**
```dart
await FirebaseCrashlytics.instance
    .setCrashlyticsCollectionEnabled(!kDebugMode);
```
and in debug, still call `FlutterError.presentError(details)` inside the handler.

### 7. 🟡 Fresh clone does not compile (Firebase config is git-ignored)
**Where:** `.gitignore:90-92` ignores `lib/firebase_options.dart`,
`GoogleService-Info.plist`, `google-services.json`; `lib/app/app.dart` →
`firebase_service.dart` hard-depends on `DefaultFirebaseOptions`.

CI works around this by writing a stub (`.github/workflows/ci.yml:39-55`), but a
human cloning the repo hits an unresolved import before they've read the docs.
For a *starter template*, first-run friction matters.

**Fix:** Commit a clearly-marked placeholder `firebase_options.dart` (like the CI
stub) **or** ship a `tool/bootstrap.sh` that runs `flutterfire configure`, and
call it out at the very top of the README's setup section.

---

## 🟢 Low / Hardening / Polish

### 8. 🟢 `AuthLocalDataSource.load()` can brick the session on corrupt JSON
**Where:** `lib/features/auth/data/datasources/auth_local_data_source.dart:64-70`.
`jsonDecode(userJson)` and the `map['id'] as String` casts are unguarded. A
corrupt/partial keychain value makes `load()` throw on every launch, and the
user can't recover without reinstalling. **Fix:** wrap in `try/catch`; on failure
treat as "no session" and `clearSession()`.

### 9. 🟢 `flutter_secure_storage` uses defaults
**Where:** `auth_local_data_source.dart:123`. No `IOSOptions`/`AndroidOptions`.
Consider an explicit iOS accessibility (`first_unlock_this_device`, to keep
tokens off iCloud-restored devices) and document the Android Keystore behavior.

### 10. 🟢 Doc comment vs. reality: when is the session loaded?
**Where:** `auth_local_data_source.dart:13-14` says `load()` "must be awaited
once during app bootstrap." It's actually awaited lazily inside
`restoreSession()` (`auth_repository_impl.dart:117`), driven by the splash
screen — `main.dart` never calls it. Align the comment with the actual flow to
avoid a future contributor "fixing" it by double-loading.

### 11. 🟢 Companion backend — fine for dev, flag before any real exposure
**Where:** `simple_backend_server/`.
- `main.go:477-528` (`uploadHandler`): the "Limit body size to 10MB" comment is
  misleading — `ParseMultipartForm(10<<20)` is the in-memory spill threshold,
  **not** a hard cap. Wrap with `http.MaxBytesReader`. No content-type/extension
  validation, and `/uploads/*` (`main.go:218`) is served publicly with no auth —
  random filenames are the only protection.
- No rate-limiting / lockout on `/api/auth/*` (brute-force) and CORS is `*`
  (`main.go:205-211`). Acceptable for a local dev server; gate/restrict before
  any shared deployment.
- ✅ Good: ownership is correctly scoped (`owner_id` on every bookmark query —
  no IDOR), bcrypt hashing, single-use rotating refresh tokens.

### 12. 🟢 Test depth & CI coverage gate
- Coverage threshold is **55%** (`ci.yml:84`), baseline ~57%. Raise the floor as
  you add tests; the offline/sync paths (items 1–3) are exactly the
  under-tested, high-risk areas.
- Golden tests and `integration_test/` don't run in CI (documented, device-bound)
  — consider a scheduled job on a macOS runner / emulator so they don't rot.

### 13. 🟢 Placeholder App Link host
**Where:** `AndroidManifest.xml:31` uses `android:host="yourdomain.com"`. Expected
for a template, but add a checklist item (and the iOS `apple-app-site-association`
/ associated-domains counterpart) to the "make it yours" docs so deep links
aren't silently broken.

---

## Quick-reference: highest-leverage fixes

| # | Severity | One-line fix | File |
|---|----------|--------------|------|
| 1 | 🔴 | Don't `clearSession()` on transient/offline refresh failure | `token_refresher.dart`, `auth_repository_impl.dart` |
| 2 | 🟠 | Per-row try/catch in `_push`; persist uploaded URLs before create | `bookmarks_sync_service.dart` |
| 3 | 🟠 | Restrict transport retries to idempotent methods | `retry_interceptor.dart` |
| 4 | 🟡 | Debug network-security-config for cleartext localhost | `android/.../AndroidManifest.xml` |
| 6 | 🟡 | `setCrashlyticsCollectionEnabled(!kDebugMode)` | `firebase_service.dart` |
| 7 | 🟡 | Commit a placeholder `firebase_options.dart` | `.gitignore`, `lib/` |

---

## What's already solid (keep it)

So this isn't only a list of complaints — the foundation is strong:

- **Clean Architecture** with real dependency inversion (data/domain/presentation,
  use-cases, repository interfaces) and `injectable`/`get_it` codegen DI.
- **Single-flight token refresh** (`TokenRefresher`) and a correct
  `_retried`-guarded 401→refresh→retry loop in `AuthInterceptor` that can't
  infinite-loop.
- **Runtime crash capture** done right — both `FlutterError.onError` and
  `PlatformDispatcher.onError` routed to Crashlytics (`firebase_service.dart`),
  plus a guarded bootstrap path with a fallback `BootstrapErrorApp`.
- **Retry interceptor** honors `Retry-After` and uses exponential backoff with
  full jitter (the only gap is method-idempotency, item 3).
- **Deep-link-aware router** that captures cold-start URIs and replays them after
  auth resolves.
- Flavors via `--dart-define-from-file`, secure token storage, i18n (en/vi),
  golden tests, and a coverage gate in CI.

---

*Generated by reviewing the live tree (analyze clean, 275 tests green). Line
numbers reference the working copy at review time; re-confirm after edits.*

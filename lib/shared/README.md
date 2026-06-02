# Shared (`shared`)

App-level *business* vocabulary genuinely used by **2+ features**. This is the
seam that lets features collaborate without importing each other's
presentation layers.

It mirrors the feature layer layout (`domain/`, `presentation/`, and `data/`
when needed) and sits between features and the lower layers: the dependency
direction is `features → shared → ui → core`.

## What lives here

- **`domain/`** — shared contracts and lightweight projections:
  - `session.dart` — `Session`, the app-wide "who is logged in" contract
    (current user + `restore`/`signOut`/`clearSession` lifecycle). It is
    `Listenable` so widgets rebuild on change.
  - `entities/auth_user.dart` — the authenticated user identity.
  - `bookmark_stats.dart` — `BookmarkSummary`, a slim cross-feature projection
    of a bookmark so consumers (e.g. the home dashboard) don't depend on the
    bookmarks feature's full `Bookmark` aggregate.
- **`presentation/`** — `session_scope.dart` exposes the `Session` to the widget
  tree via an `InheritedWidget`; read it with `SessionScope.of(context)` and
  rebuild with a `ListenableBuilder`.

## Worked example — the session

"Who is logged in" is read by `home`, `profile`, and `splash`. Instead of those
features importing the auth feature's `AuthBloc` (a presentation-layer type),
they depend on the `Session` contract here. The auth feature provides the
implementation (`AuthSession`, an adapter over `AuthBloc`); the composition root
(`lib/app/app.dart`) wires it and exposes it through `SessionScope`.

## The rule of three

Promote a type into `shared` only when **≥2 features actually depend on it
today** (not "might someday") and its contract is stable. Until then it stays in
its owning feature. Keep `shared` a small, deliberate set of contracts — never a
catch-all dumping ground. A feature-specific *capability* (a presentation object
one feature surfaces inside another) stays in its owning feature while a single
consumer exists, and graduates here only when a second consumer appears.

Reusable *non-visual infrastructure* belongs in `lib/core/` or a workspace package
package; generic *visual* building blocks belong in `app_ui`. `shared` is only
for shared **business** state and contracts.

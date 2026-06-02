# core_storage

App storage primitives for the Flutter starter template. Exported through
`package:core_storage/core_storage.dart`.

The barrel re-exports `shared_preferences` and `flutter_secure_storage`, so the
app gets those types through this package.

## Public API

- `SharedPreferencesModule` — provides the app-wide `SharedPreferences`
  instance through DI (registered as `CoreStoragePackageModule`).
- `KeychainResetOnReinstall` — clears stale secure storage on the first launch
  after an install (see below).
- `CoreStoragePackageModule` — the injectable micro-package module the app
  registers via `externalPackageModulesBefore`.

## The iOS Keychain reinstall reset

iOS keeps Keychain data (where `flutter_secure_storage` lives) across app
uninstalls, so a reinstall would inherit stale auth tokens.
`KeychainResetOnReinstall.run()` — called in `main()` right after
`configureDependencies()`, before session restore reads secure storage — wipes
all secure storage on the first launch after install. It detects "first launch"
via a flag in `SharedPreferences` (NSUserDefaults *is* cleared on uninstall).

## Notes

`SharedPreferences` provisioning lives here because two consumers need it
(`core_theme`'s `ThemeBloc` and the reinstall reset), so `core_storage` must be
registered **before** `core_theme` in the app's DI composition.

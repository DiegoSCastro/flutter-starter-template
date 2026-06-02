# core_config

App configuration — environment values + Firebase Remote Config — for the
Flutter starter template. Exported through
`package:core_config/core_config.dart`.

## Public API

- `EnvConfig` — typed runtime configuration read from `--dart-define`
  (`String.fromEnvironment`): API base URL, timeouts, flavor name, and
  `isDev`/`isStaging`/`isProd`. Values come from the `env/*.json` files (see
  [`env/README.md`](../../env/README.md)).
- `RemoteConfigService` — a wrapper over Firebase Remote Config for
  server-driven feature flags and values.
- `CoreConfigPackageModule` — the injectable micro-package module the app
  registers via `externalPackageModulesBefore`.

## Notes

`EnvConfig` is a dependency of `core_network` (`NetworkModule` reads the API
base URL and timeout), so this module must be registered **before**
`core_network` in the app's DI composition.

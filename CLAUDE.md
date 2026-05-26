# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Flutter version is pinned via FVM

This project pins Flutter to the version in `.fvmrc` (currently 3.44.0) using [FVM](https://fvm.app/). Always invoke Flutter through FVM so the pinned SDK is used; running a globally-installed `flutter` may silently use the wrong version.

```bash
fvm flutter <command>          # e.g. fvm flutter run, fvm flutter pub get
fvm dart <command>             # for Dart-only tooling
```

If `.fvm/flutter_sdk` is missing, run `fvm install` once to materialize it.

## Common commands

```bash
fvm flutter pub get                          # install dependencies
fvm flutter run                              # run on the default device (debug)
fvm flutter run --profile                    # profile mode
fvm flutter run --release                    # release mode
fvm flutter analyze                          # static analysis (uses analysis_options.yaml)
fvm flutter test                             # run all tests
fvm flutter test test/widget_test.dart       # run a single test file
fvm flutter test --name "<substring>"        # run tests whose name matches
fvm flutter build apk | ipa | web            # platform builds
```

VS Code launch configs in `.vscode/launch.json` cover Debug / Profile / Release modes against `lib/main.dart`.

## Lints

`analysis_options.yaml` extends `package:flutter_lints/flutter.yaml`. Project-specific rule overrides go under `linter.rules` in that file.

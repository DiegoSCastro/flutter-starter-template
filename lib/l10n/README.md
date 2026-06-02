# Localization (`l10n`)

This directory contains the localization and internationalization resources for the Flutter application. 

The project uses the official `flutter_localizations` package to generate strongly-typed Dart classes from Application Resource Bundle (`.arb`) files.

## Files Structure

- `*.arb` files: The source of truth for all translations.
  - `app_en.arb`: The **template file** containing English strings. Always add new keys and descriptions to this file first.
  - `app_vi.arb`: The Vietnamese translations (and any other supported languages will follow the `app_<language_code>.arb` format).
- `*.dart` files: The **generated** Dart files. Do not manually edit these files! They are regenerated automatically based on the `.arb` files.

## Adding or Updating Translations

To add a new localized string or update an existing one:

1. **Update the Template File:** Open `app_en.arb` and add your new key-value pair. You can also provide metadata like descriptions or placeholders.
   ```json
   "helloWorld": "Hello World!",
   "@helloWorld": {
     "description": "The conventional newborn programmer greeting"
   }
   ```
2. **Update Translations:** Add the same key with the corresponding translated value to all other `.arb` files (e.g., `app_vi.arb`).
   ```json
   "helloWorld": "Chào thế giới!"
   ```
3. **Regenerate the Dart Files:** 
   Run the following command to regenerate the Dart localization classes.
   ```bash
   fvm flutter gen-l10n
   ```

## Usage in Code

To use the generated localizations in your UI code, use `AppLocalizations.of(context)`. Because `nullable-getter: false` is set in `l10n.yaml`, the getter returns a non-null `AppLocalizations`, so no `!` is needed:

```dart
import 'package:flutter_starter_template/l10n/app_localizations.dart';

// ... inside a widget's build method
Text(AppLocalizations.of(context).helloWorld);
```

Alternatively, you can use the `BuildContext` extension if one is provided in the project:
```dart
Text(context.l10n.helloWorld);
```

## Configuration

The localization generator is configured via the `l10n.yaml` file located in the root of the project.

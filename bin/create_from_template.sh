#!/usr/bin/env bash
#
# Generate a new Flutter project from this template.
#
# Usage: bin/create_from_template.sh <app_name> [destination_dir]
#
#   <app_name>        Lowercase, hyphenated, must match Dart's `pub package
#                     name` rules (e.g. `contador-de-dias`, `sundial-app`).
#   [destination_dir] Where to create the project. Defaults to the current
#                     working directory. The project itself is created at
#                     `<destination_dir>/<app_name>`.
#
# What it does:
#   1. Clones this template into <destination_dir>/<app_name> as a fresh git
#      repo (no history carried over).
#   2. Rewrites project metadata to match <app_name>:
#        - pubspec.yaml          → name + description
#        - Android applicationId + namespace + flavor display names
#        - iOS bundle id + CFBundleName
#   3. Removes template-only artifacts that don't make sense in a fresh
#      project (e.g. firebase_options.dart, ObjectBox bindings, CI workflows
#      tagged "template-only" — extend the strip list as the template grows).
#   4. Runs `flutter pub get` + `dart run build_runner build` + `flutter
#      analyze` and refuses to leave the destination if the analyzer reports
#      any issues.
#
# Requires: git, flutter (3.12+), dart on PATH.
#
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  sed -n '3,21p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 1
fi

app_name="$1"
destination="${2:-$PWD}"

# --- preflight --------------------------------------------------------------
if ! command -v git >/dev/null 2>&1; then
  echo "✖ git not found in PATH." >&2
  exit 1
fi
if ! command -v flutter >/dev/null 2>&1; then
  echo "✖ flutter not found in PATH." >&2
  exit 1
fi

# Dart package name rules: lowercase, [_0-9a-z], start with a letter.
# We also allow hyphens and convert them to underscores for the Dart package
# name (Dart's `pub` does not accept hyphens).
if [[ ! "$app_name" =~ ^[a-z][a-z0-9_-]*$ ]]; then
  echo "✖ app_name must be lowercase, start with a letter, and may only" >&2
  echo "  contain letters, digits, underscores, and hyphens." >&2
  echo "  Got: $app_name" >&2
  exit 1
fi

dart_pkg_name="${app_name//-/_}"

# Android applicationId and iOS bundle id: dots, lowercase alnum, each
# segment must start with a letter.
org_id="$dart_pkg_name"
if [[ ! "$org_id" =~ ^[a-z][a-z0-9_]*$ ]] || [[ "$org_id" == *_ ]]; then
  echo "✖ '$app_name' cannot be turned into a valid Android applicationId /" >&2
  echo "  iOS bundle id automatically. Wrap it manually after the script" >&2
  echo "  finishes (see android/app/build.gradle.kts and the Xcode project)." >&2
  echo "  Got candidate: $org_id" >&2
  exit 1
fi

target_dir="$destination/$app_name"
if [[ -e "$target_dir" ]]; then
  echo "✖ Destination already exists: $target_dir" >&2
  exit 1
fi

# --- 1. clone the template -------------------------------------------------
template_url="$(git -C "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" config --get remote.origin.url)"
if [[ -z "$template_url" ]]; then
  echo "✖ Could not determine the template's remote URL. Run this from a" >&2
  echo "  clone of flutter-starter-template." >&2
  exit 1
fi

echo "▶ create: cloning template into $target_dir..."
git clone --depth 1 "$template_url" "$target_dir"

# Drop the template's git history and start fresh.
rm -rf "$target_dir/.git"
git -C "$target_dir" init -q
git -C "$target_dir" checkout -q -b main

# --- 2. rewrite project metadata ------------------------------------------
echo "▶ create: rewriting project metadata for '$app_name'…"

# pubspec.yaml — name + description
sed -i '' \
  -e "s|^name: .*|name: $dart_pkg_name|" \
  -e "s|^description: .*|description: \"Generated from flutter-starter-template.\"|" \
  "$target_dir/pubspec.yaml"

# Android: applicationId, namespace, flavor display names
sed -i '' \
  -e "s|com\.lucistudio\.flutter_starter_template|com.$org_id|g" \
  -e "s|Flutter Starter (Dev)|$app_name (Dev)|g" \
  -e "s|Flutter Starter (Staging)|$app_name (Staging)|g" \
  -e "s|Flutter Starter|$app_name|g" \
  "$target_dir/android/app/build.gradle.kts"

# iOS: PRODUCT_BUNDLE_IDENTIFIER + CFBundleName
sed -i '' "s|com\.luci-studio\.flutterStarterTemplate|com.$org_id|g" \
  "$target_dir/ios/Runner.xcodeproj/project.pbxproj"
sed -i '' "s|<string>flutter_starter_template</string>|<string>$app_name</string>|" \
  "$target_dir/ios/Runner/Info.plist"

# --- 3. remove template-only artifacts ------------------------------------
# Firebase / ObjectBox / freezed codegen leave generated files that point at
# template-specific entities. A fresh project should rebuild them.
#
# Tests reference template-specific blocs (auth, bookmarks, …); strip them
# too — the new project can author its own tests from scratch.
#
# `integration_test/` and `simple_backend_server/` (if cloned via submodule
# during setup) are template-only scaffolding for end-to-end tests and the
# Go companion backend; neither belongs in a fresh project.
echo "▶ create: removing template-only artifacts…"
rm -f "$target_dir/lib/firebase_options.dart" \
      "$target_dir/lib/objectbox.g.dart" \
      "$target_dir/lib/objectbox-model.json" \
      "$target_dir/lib/main.dart" \
      "$target_dir/lib/app/app.dart" \
      "$target_dir/lib/app/router.dart" \
      "$target_dir/lib/app/bootstrap_error_app.dart" \
      "$target_dir/lib/app/di/injection.dart" \
      "$target_dir/lib/app/widgets/app_shell.dart"
rm -rf "$target_dir/test" \
       "$target_dir/integration_test" \
       "$target_dir/simple_backend_server" \
       "$target_dir/test_driver" \
       "$target_dir/lib/core/platform/firebase" \
       "$target_dir/lib/app"

# Drop template-specific screens/blocs/data. Authors of the new project
# recreate these under `lib/features/<feature>/...` and `lib/core/data/...`.
rm -rf "$target_dir/lib/features" \
       "$target_dir/lib/core/data" \
       "$target_dir/lib/core/extensions" \
       "$target_dir/lib/core/platform" \
       "$target_dir/lib/l10n" \
       "$target_dir/lib/shared"

# `l10n.yaml` references a directory we just deleted; remove it so the new
# project can re-enable localization when it's actually needed.
rm -f "$target_dir/l10n.yaml"

# Strip localization generation flags from pubspec.yaml — without ARB files
# the synthetic l10n pass fails. Authors opt back in by adding ARB files and
# re-setting `generate: true`.
sed -i '' \
  -e '/^  # Enables generation of localized strings from ARB files/d' \
  -e '/^  # i18n pipeline/,/^  # /d' \
  "$target_dir/pubspec.yaml" 2>/dev/null || true
sed -i '' '/^  generate: true$/d' "$target_dir/pubspec.yaml" 2>/dev/null || true

# --- 4. run codegen + analyze ---------------------------------------------
echo "▶ create: running pub get…"
(cd "$target_dir" && flutter pub get)

echo "▶ create: running build_runner (codegen)…"
(cd "$target_dir" && dart run build_runner build --delete-conflicting-outputs)

echo "▶ create: running flutter analyze…"
if ! (cd "$target_dir" && flutter analyze); then
  echo "✖ flutter analyze reported issues in the generated project." >&2
  echo "  Inspect $target_dir and fix them before opening a PR." >&2
  exit 1
fi

# --- 5. summary ------------------------------------------------------------
cat <<EOF

✓ Created $target_dir

Next steps:
  cd $target_dir
  ./bin/install-hooks.sh           # enable the pre-push hook (build_runner + format + analyze)
  git add -A
  git commit -m "feat: initial scaffold from flutter-starter-template"
  git remote add origin git@github.com:<your-org>/$app_name.git
  git push -u origin main          # the hook will run before the push

  # then run the app:
  flutter run
EOF

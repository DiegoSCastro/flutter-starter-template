# iOS Fastlane — TestFlight

A scaffold for building each flavor (`dev` / `staging` / `prod`) and uploading
it to TestFlight. All account-specific values live in `fastlane/.env`, which is
git-ignored, so this template ships with **no secrets and nothing to scrub**
before reuse on a new project.

## One-time setup

1. **Ruby + bundler.** The lanes need Ruby ≥ 2.7 (macOS system Ruby 2.6 is too
   old for current fastlane). Install a newer Ruby via `rbenv`/`asdf`, then:

   ```bash
   cd ios
   gem install bundler
   bundle install
   ```

2. **App Store Connect API key.** In App Store Connect → *Users and Access →
   Integrations → App Store Connect API*, create a key with *App Manager* (or
   higher) access and download the `AuthKey_XXXX.p8` (you can only download it
   once). Keep the `.p8` outside the repo.

3. **Configure `.env`.**

   ```bash
   cp fastlane/.env.example fastlane/.env
   # then fill in the values; for the key:
   base64 -i /path/to/AuthKey_XXXX.p8 | pbcopy   # paste as APP_STORE_CONNECT_API_KEY_CONTENT
   ```

4. **Bundle id.** Make sure the app exists in App Store Connect for each flavor
   you ship. The lane derives the id from `IOS_BUNDLE_ID_BASE` plus the flavor
   suffix (`.dev`, `.staging`, none for prod).

## Usage

```bash
cd ios
bundle exec fastlane beta flavor:prod      # prod → TestFlight
bundle exec fastlane beta flavor:staging
bundle exec fastlane beta flavor:dev
```

The `beta` lane: compiles with `flutter build ios --no-codesign --flavor <f>`,
archives + signs via `build_app` (`-allowProvisioningUpdates`, so signing
assets are resolved automatically using the API key), then uploads to
TestFlight.

## CI notes

- Must run on **macOS** runners (Xcode required).
- Provide the same variables as repository secrets and export them into the
  environment; set `FLUTTER_CMD=flutter` since CI puts Flutter on `PATH`
  directly (no FVM).
- This repo's existing `.github/workflows/ci.yml` is analyze/test only and is
  intentionally left unchanged — wire a separate release workflow (e.g. on tag
  push) that calls `bundle exec fastlane beta flavor:prod` when you're ready.

## Signing alternatives

This scaffold uses automatic signing via the API key, which is the
lowest-setup path. For reproducible team signing, swap in
[`match`](https://docs.fastlane.tools/actions/match/) (stores certs/profiles in
a private git repo) — add a `match` call before `build_app` and set
`build_app(... export_options: { signingStyle: "manual" })`.

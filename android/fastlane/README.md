# Android Fastlane — Google Play

A scaffold for building each flavor (`dev` / `staging` / `prod`) as a signed
app bundle and uploading it to Google Play. All account-specific values live in
`fastlane/.env` and `android/key.properties`, both git-ignored, so this template
ships with **no secrets and nothing to scrub** before reuse on a new project.

## One-time setup

1. **Ruby + bundler.** The lanes need Ruby ≥ 2.7 (macOS system Ruby 2.6 is too
   old for current fastlane). Install a newer Ruby via `rbenv`/`asdf`, then:

   ```bash
   cd android
   gem install bundler
   bundle install
   ```

2. **Release signing.** Generate an upload keystore and wire it up — without
   this, release builds fall back to the *debug* keystore and Play will reject
   them:

   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -storetype JKS \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   cp key.properties.example key.properties   # then fill in paths/passwords
   ```

   `android/app/build.gradle.kts` loads `key.properties` automatically when
   present.

3. **Play service account.** In the Google Play Console (*Users and
   permissions*), grant a Google Cloud service account release access, download
   its JSON key, and store it **outside the repo**.

4. **Configure `.env`.**

   ```bash
   cp fastlane/.env.example fastlane/.env
   # set PLAY_STORE_JSON_KEY_PATH to the JSON key, and ANDROID_PACKAGE_NAME_BASE
   ```

5. **First upload must be manual.** Google Play requires the very first build
   of a package to be uploaded by hand in the Console; fastlane can take over
   for every release after that.

## Usage

```bash
cd android
bundle exec fastlane beta flavor:prod       # prod → Play internal track
bundle exec fastlane beta flavor:staging
bundle exec fastlane beta flavor:dev
```

The `beta` lane: builds with `flutter build appbundle --flavor <f>`, then
uploads the `.aab` to the flavor's Play track as a **draft** release. Change
`release_status` to `"completed"` in the `Fastfile` to publish straight to the
track's testers, or pass `track:` to target a different track
(`bundle exec fastlane beta flavor:prod track:beta`).

## CI notes

- Runs on Linux or macOS (no Xcode needed for Android).
- Provide the variables as repository secrets and export them into the
  environment; set `FLUTTER_CMD=flutter` since CI puts Flutter on `PATH`
  directly (no FVM).
- Materialize `key.properties` and the keystore from secrets at job start
  (e.g. base64-decode them into place), then run the lane.
- This repo's `.github/workflows/ci.yml` is analyze/test only and is left
  unchanged — wire a separate release workflow (e.g. on tag push) when ready.

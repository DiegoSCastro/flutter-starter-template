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

The `beta` lane: builds with `flutter build appbundle --flavor <f>
--build-number <n>`, then uploads the `.aab` to the flavor's Play track as a
**draft** release. Change `release_status` to `"completed"` in the `Fastfile`
to publish straight to the track's testers, or pass `track:` to target a
different track (`bundle exec fastlane beta flavor:prod track:beta`).

### Build numbers

Play rejects a duplicate or non-increasing `versionCode`. The lane sets it
from, in order: a `build_number:` arg, the `BUILD_NUMBER` env var (CI sets
this), else the git commit count. Pass one explicitly when needed:

```bash
bundle exec fastlane beta flavor:prod build_number:42
```

## CI

`.github/workflows/release.yml` runs this lane on `ubuntu-latest` (no Xcode
needed) on tag push / manual dispatch, with `FLUTTER_CMD=flutter` and
`BUILD_NUMBER` from the run number. The workflow restores `key.properties`, the
keystore, `google-services.json`, and the Play key file from secrets, then runs
the lane. Expected repository secrets/vars:

| Name | Kind | Purpose |
|---|---|---|
| `ANDROID_PACKAGE_NAME_BASE` | var | Base applicationId |
| `PLAY_STORE_JSON_KEY` | secret | Play service-account JSON (raw contents) |
| `ANDROID_KEYSTORE_BASE64` | secret | base64 of the upload keystore |
| `ANDROID_KEYSTORE_PASSWORD` | secret | Keystore password |
| `ANDROID_KEY_PASSWORD` | secret | Key password |
| `ANDROID_KEY_ALIAS` | secret | Key alias |
| `ANDROID_GOOGLE_SERVICES_JSON` | secret | base64 of `google-services.json` (git-ignored) |

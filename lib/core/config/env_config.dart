import 'package:injectable/injectable.dart';

@singleton
class EnvConfig {
  const EnvConfig();

  String get flavor =>
      const String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  String get androidApiKey =>
      const String.fromEnvironment('FIREBASE_ANDROID_API_KEY');

  String get androidAppId =>
      const String.fromEnvironment('FIREBASE_ANDROID_APP_ID');

  String get androidMessagingSenderId =>
      const String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID');

  String get androidProjectId =>
      const String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID');

  String get androidStorageBucket =>
      const String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET');

  String get iosApiKey => const String.fromEnvironment('FIREBASE_IOS_API_KEY');

  String get iosAppId => const String.fromEnvironment('FIREBASE_IOS_APP_ID');

  String get iosMessagingSenderId =>
      const String.fromEnvironment('FIREBASE_IOS_MESSAGING_SENDER_ID');

  String get iosProjectId =>
      const String.fromEnvironment('FIREBASE_IOS_PROJECT_ID');

  String get iosStorageBucket =>
      const String.fromEnvironment('FIREBASE_IOS_STORAGE_BUCKET');

  String get iosClientId =>
      const String.fromEnvironment('FIREBASE_IOS_CLIENT_ID');

  String get iosBundleId =>
      const String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

  bool get isDev => flavor == 'dev';
  bool get isStaging => flavor == 'staging';
  bool get isProd => flavor == 'prod';
}

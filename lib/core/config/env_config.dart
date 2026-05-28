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

  bool get isDev => flavor == 'dev';
  bool get isStaging => flavor == 'staging';
  bool get isProd => flavor == 'prod';
}

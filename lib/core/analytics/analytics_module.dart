import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AnalyticsModule {
  @lazySingleton
  FirebaseAnalytics provideFirebaseAnalytics() => FirebaseAnalytics.instance;
}

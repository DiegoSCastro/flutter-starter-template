import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});

  Future<void> logLogin({required String method});

  Future<void> logScreenView({required String screenName});

  Future<void> setCurrentUser(String? userId);

  Future<void> setUserProperty({required String name, required String? value});
}

@LazySingleton(as: AnalyticsService)
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) {
    return _guard(
      () => _analytics.logEvent(name: name, parameters: parameters),
    );
  }

  @override
  Future<void> logLogin({required String method}) {
    return _guard(() => _analytics.logLogin(loginMethod: method));
  }

  @override
  Future<void> logScreenView({required String screenName}) {
    return _guard(() => _analytics.logScreenView(screenName: screenName));
  }

  @override
  Future<void> setCurrentUser(String? userId) {
    return _guard(() => _analytics.setUserId(id: userId));
  }

  @override
  Future<void> setUserProperty({required String name, required String? value}) {
    return _guard(() => _analytics.setUserProperty(name: name, value: value));
  }

  Future<void> _guard(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Analytics error: $error');
      }
    }
  }
}

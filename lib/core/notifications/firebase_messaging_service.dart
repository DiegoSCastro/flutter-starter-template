import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../analytics/analytics_events.dart';
import '../analytics/analytics_service.dart';
import 'notifications_service.dart';

typedef OnNotificationTap = void Function(Map<String, dynamic>? data);

@singleton
class FirebaseMessagingService {
  FirebaseMessagingService(
    this._localNotifications,
    this._messaging,
    this._analytics,
  );

  final NotificationsService _localNotifications;
  final FirebaseMessaging _messaging;
  final AnalyticsService _analytics;

  final _tokenStream = StreamController<String?>.broadcast();

  OnNotificationTap? onNotificationTap;

  Stream<String?> get onTokenRefresh => _tokenStream.stream;

  Future<void> init() async {
    // Don't request permission on web — handled by browser APIs.
    if (kIsWeb) return;

    final notificationsAllowed = await _localNotifications.requestPermissions();
    if (!notificationsAllowed) return;

    await _saveInitialToken();

    if (Platform.isIOS || Platform.isMacOS) {
      // APNs token registration — required for iOS push delivery.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    // Handle messages while app is in the foreground.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handle when user taps a notification that brings the app from background.
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpened);

    // Handle when user taps a notification that launched the app from terminated state.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> _saveInitialToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      _tokenStream.add(token);
    }
  }

  void _onTokenRefresh(String token) {
    _tokenStream.add(token);
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title ?? '',
      body: notification.body ?? '',
      payload: _serializeData(message.data),
    );
  }

  void _onNotificationOpened(RemoteMessage message) {
    _handleNotificationTap(message.data);
  }

  void _handleNotificationTap(Map<String, dynamic>? data) {
    unawaited(
      _analytics.logEvent(
        AnalyticsEvents.notificationOpened,
        parameters: {AnalyticsParams.payloadKeyCount: data?.length ?? 0},
      ),
    );
    final callback = onNotificationTap;
    if (callback != null) {
      callback(data);
    }
  }

  String? _serializeData(Map<String, dynamic> data) {
    if (data.isEmpty) return null;
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }
}

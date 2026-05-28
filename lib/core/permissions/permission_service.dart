import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

typedef PermissionStatusLoader = Future<PermissionStatus> Function();
typedef PermissionRationaleLoader = Future<bool> Function();
typedef AppSettingsOpener = Future<bool> Function();

/// App-level wrapper around `permission_handler`.
///
/// Keep direct plugin calls here so feature and notification services depend on
/// app semantics instead of plugin-specific APIs.
@lazySingleton
class PermissionService {
  PermissionService()
    : this.custom(
        () => Permission.notification.status,
        () => Permission.notification.request(),
        () => Permission.notification.shouldShowRequestRationale,
        openAppSettings,
      );

  @visibleForTesting
  PermissionService.custom(
    this._notificationStatus,
    this._requestNotification,
    this._notificationRationale,
    this._openSettings,
  );

  final PermissionStatusLoader _notificationStatus;
  final PermissionStatusLoader _requestNotification;
  final PermissionRationaleLoader _notificationRationale;
  final AppSettingsOpener _openSettings;

  Future<PermissionStatus> notificationStatus() {
    if (kIsWeb) return Future.value(PermissionStatus.denied);
    return _notificationStatus();
  }

  Future<bool> hasNotificationPermission() async {
    return isNotificationAllowed(await notificationStatus());
  }

  Future<PermissionStatus> requestNotificationStatus() {
    if (kIsWeb) return Future.value(PermissionStatus.denied);
    return _requestNotification();
  }

  Future<bool> requestNotificationPermission() async {
    return isNotificationAllowed(await requestNotificationStatus());
  }

  Future<bool> shouldShowNotificationPermissionRationale() {
    if (kIsWeb) return Future.value(false);
    return _notificationRationale();
  }

  Future<bool> openAppSettingsPage() {
    if (kIsWeb) return Future.value(false);
    return _openSettings();
  }

  /// iOS provisional authorization can display notifications quietly.
  bool isNotificationAllowed(PermissionStatus status) {
    return status.isGranted || status.isProvisional;
  }
}

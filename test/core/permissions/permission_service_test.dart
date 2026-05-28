import 'package:flutter_starter_template/core/permissions/permission_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('PermissionService', () {
    PermissionService buildService({
      PermissionStatus status = PermissionStatus.denied,
      PermissionStatus requestStatus = PermissionStatus.denied,
      bool shouldShowRationale = false,
      bool appSettingsOpened = false,
    }) {
      return PermissionService.custom(
        () async => status,
        () async => requestStatus,
        () async => shouldShowRationale,
        () async => appSettingsOpened,
      );
    }

    test('treats granted and provisional notification status as allowed', () {
      final service = buildService();

      expect(service.isNotificationAllowed(PermissionStatus.granted), isTrue);
      expect(
        service.isNotificationAllowed(PermissionStatus.provisional),
        isTrue,
      );
    });

    test('treats non-notification-enabled statuses as not allowed', () {
      final service = buildService();

      for (final status in [
        PermissionStatus.denied,
        PermissionStatus.restricted,
        PermissionStatus.limited,
        PermissionStatus.permanentlyDenied,
      ]) {
        expect(service.isNotificationAllowed(status), isFalse);
      }
    });

    test('reads current notification permission status', () async {
      final service = buildService(status: PermissionStatus.granted);

      expect(await service.notificationStatus(), PermissionStatus.granted);
      expect(await service.hasNotificationPermission(), isTrue);
    });

    test(
      'requests notification permission and returns app-level allowance',
      () async {
        final service = buildService(
          requestStatus: PermissionStatus.provisional,
        );

        expect(
          await service.requestNotificationStatus(),
          PermissionStatus.provisional,
        );
        expect(await service.requestNotificationPermission(), isTrue);
      },
    );

    test('delegates rationale and settings helpers', () async {
      final service = buildService(
        shouldShowRationale: true,
        appSettingsOpened: true,
      );

      expect(await service.shouldShowNotificationPermissionRationale(), isTrue);
      expect(await service.openAppSettingsPage(), isTrue);
    });
  });
}

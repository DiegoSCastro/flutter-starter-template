// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:core_analytics/core_analytics.dart' as _i682;
import 'package:core_platform/src/media/camera_service.dart' as _i114;
import 'package:core_platform/src/media/image_picker_service.dart' as _i326;
import 'package:core_platform/src/media/media_module.dart' as _i573;
import 'package:core_platform/src/media/video_player_service.dart' as _i595;
import 'package:core_platform/src/notifications/firebase_messaging_service.dart'
    as _i615;
import 'package:core_platform/src/notifications/notifications_module.dart'
    as _i866;
import 'package:core_platform/src/notifications/notifications_service.dart'
    as _i686;
import 'package:core_platform/src/permissions/permission_service.dart'
    as _i1040;
import 'package:core_platform/src/share/share_module.dart' as _i1030;
import 'package:core_platform/src/share/share_service.dart' as _i964;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;
import 'package:share_plus/share_plus.dart' as _i998;

class CorePlatformPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final mediaModule = _$MediaModule();
    final notificationsModule = _$NotificationsModule();
    final shareModule = _$ShareModule();
    gh.lazySingleton<_i114.CameraService>(() => _i114.CameraService());
    gh.lazySingleton<_i183.ImagePicker>(() => mediaModule.imagePicker);
    gh.lazySingleton<_i595.VideoPlayerService>(
      () => _i595.VideoPlayerService(),
    );
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => notificationsModule.providePlugin(),
    );
    gh.lazySingleton<_i892.FirebaseMessaging>(
      () => notificationsModule.provideFirebaseMessaging(),
    );
    gh.lazySingleton<_i1040.PermissionService>(
      () => _i1040.PermissionService(),
    );
    gh.lazySingleton<_i998.SharePlus>(() => shareModule.provideSharePlus());
    gh.lazySingleton<_i326.ImagePickerService>(
      () => _i326.ImagePickerService(gh<_i183.ImagePicker>()),
    );
    gh.lazySingleton<_i964.ShareService>(
      () => _i964.ShareService(gh<_i998.SharePlus>()),
    );
    gh.lazySingleton<_i686.NotificationsService>(
      () => _i686.NotificationsService(
        gh<_i163.FlutterLocalNotificationsPlugin>(),
        gh<_i1040.PermissionService>(),
      ),
    );
    gh.lazySingleton<_i615.FirebaseMessagingService>(
      () => _i615.FirebaseMessagingService(
        gh<_i686.NotificationsService>(),
        gh<_i892.FirebaseMessaging>(),
        gh<_i682.AnalyticsService>(),
      ),
    );
  }
}

class _$MediaModule extends _i573.MediaModule {}

class _$NotificationsModule extends _i866.NotificationsModule {}

class _$ShareModule extends _i1030.ShareModule {}

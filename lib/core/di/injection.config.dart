// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_analytics/firebase_analytics.dart' as _i398;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:flutter_starter_template/core/analytics/analytics_module.dart'
    as _i720;
import 'package:flutter_starter_template/core/analytics/analytics_route_observer.dart'
    as _i873;
import 'package:flutter_starter_template/core/analytics/analytics_service.dart'
    as _i838;
import 'package:flutter_starter_template/core/config/env_config.dart' as _i689;
import 'package:flutter_starter_template/core/firebase/firebase_service.dart'
    as _i999;
import 'package:flutter_starter_template/core/media/camera_service.dart'
    as _i756;
import 'package:flutter_starter_template/core/media/image_picker_service.dart'
    as _i735;
import 'package:flutter_starter_template/core/media/media_module.dart' as _i773;
import 'package:flutter_starter_template/core/media/video_player_service.dart'
    as _i863;
import 'package:flutter_starter_template/core/network/network_module.dart'
    as _i173;
import 'package:flutter_starter_template/core/notifications/firebase_messaging_service.dart'
    as _i529;
import 'package:flutter_starter_template/core/notifications/notifications_module.dart'
    as _i146;
import 'package:flutter_starter_template/core/notifications/notifications_service.dart'
    as _i332;
import 'package:flutter_starter_template/core/permissions/permission_service.dart'
    as _i213;
import 'package:flutter_starter_template/core/share/share_module.dart' as _i390;
import 'package:flutter_starter_template/core/share/share_service.dart'
    as _i580;
import 'package:flutter_starter_template/core/theme/theme_bloc.dart' as _i652;
import 'package:flutter_starter_template/features/auth/data/datasources/auth_local_data_source.dart'
    as _i297;
import 'package:flutter_starter_template/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i87;
import 'package:flutter_starter_template/features/auth/data/network/auth_network_module.dart'
    as _i740;
import 'package:flutter_starter_template/features/auth/data/network/token_refresher.dart'
    as _i533;
import 'package:flutter_starter_template/features/auth/data/repositories/auth_repository_impl.dart'
    as _i1028;
import 'package:flutter_starter_template/features/auth/domain/repositories/auth_repository.dart'
    as _i987;
import 'package:flutter_starter_template/features/auth/domain/usecases/change_password.dart'
    as _i780;
import 'package:flutter_starter_template/features/auth/domain/usecases/register.dart'
    as _i699;
import 'package:flutter_starter_template/features/auth/domain/usecases/restore_session.dart'
    as _i271;
import 'package:flutter_starter_template/features/auth/domain/usecases/sign_in.dart'
    as _i1001;
import 'package:flutter_starter_template/features/auth/domain/usecases/sign_out.dart'
    as _i926;
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_bloc.dart'
    as _i269;
import 'package:flutter_starter_template/features/auth/presentation/bloc/change_password_cubit.dart'
    as _i11;
import 'package:flutter_starter_template/features/bookmarks/data/datasources/bookmarks_remote_data_source.dart'
    as _i729;
import 'package:flutter_starter_template/features/bookmarks/data/datasources/bookmarks_remote_module.dart'
    as _i235;
import 'package:flutter_starter_template/features/bookmarks/data/local/bookmarks_local_data_source.dart'
    as _i724;
import 'package:flutter_starter_template/features/bookmarks/data/local/object_box.dart'
    as _i319;
import 'package:flutter_starter_template/features/bookmarks/data/repositories/bookmarks_repository_impl.dart'
    as _i73;
import 'package:flutter_starter_template/features/bookmarks/data/sync/bookmarks_sync_service.dart'
    as _i539;
import 'package:flutter_starter_template/features/bookmarks/domain/repositories/bookmarks_repository.dart'
    as _i630;
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmarks_sync_controller.dart'
    as _i627;
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/create_bookmark.dart'
    as _i632;
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/delete_bookmark.dart'
    as _i244;
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/get_bookmark.dart'
    as _i690;
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/list_bookmarks.dart'
    as _i568;
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/update_bookmark.dart'
    as _i412;
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmark_detail/bookmark_detail_bloc.dart'
    as _i373;
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmark_form/bookmark_form_bloc.dart'
    as _i540;
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmarks_list/bookmarks_list_bloc.dart'
    as _i566;
import 'package:flutter_starter_template/features/home/presentation/bloc/home_bloc.dart'
    as _i423;
import 'package:flutter_starter_template/features/profile/presentation/bloc/profile_bloc.dart'
    as _i1013;
import 'package:flutter_starter_template/objectbox.g.dart' as _i831;
import 'package:get_it/get_it.dart' as _i174;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;
import 'package:share_plus/share_plus.dart' as _i998;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:uuid/uuid.dart' as _i706;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final sharedPreferencesModule = _$SharedPreferencesModule();
    final objectBoxModule = _$ObjectBoxModule();
    final analyticsModule = _$AnalyticsModule();
    final mediaModule = _$MediaModule();
    final notificationsModule = _$NotificationsModule();
    final shareModule = _$ShareModule();
    final secureStorageModule = _$SecureStorageModule();
    final pluginsModule = _$PluginsModule();
    final networkModule = _$NetworkModule();
    final authNetworkModule = _$AuthNetworkModule();
    final bookmarksRemoteModule = _$BookmarksRemoteModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.provideSharedPreferences(),
      preResolve: true,
    );
    gh.factory<_i1013.ProfileBloc>(() => _i1013.ProfileBloc());
    gh.singleton<_i689.EnvConfig>(() => const _i689.EnvConfig());
    gh.singleton<_i999.FirebaseService>(() => _i999.FirebaseService());
    await gh.singletonAsync<_i319.ObjectBox>(
      () => objectBoxModule.provideObjectBox(),
      preResolve: true,
    );
    gh.lazySingleton<_i398.FirebaseAnalytics>(
      () => analyticsModule.provideFirebaseAnalytics(),
    );
    gh.lazySingleton<_i756.CameraService>(() => _i756.CameraService());
    gh.lazySingleton<_i183.ImagePicker>(() => mediaModule.imagePicker);
    gh.lazySingleton<_i863.VideoPlayerService>(
      () => _i863.VideoPlayerService(),
    );
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => notificationsModule.providePlugin(),
    );
    gh.lazySingleton<_i892.FirebaseMessaging>(
      () => notificationsModule.provideFirebaseMessaging(),
    );
    gh.lazySingleton<_i213.PermissionService>(() => _i213.PermissionService());
    gh.lazySingleton<_i998.SharePlus>(() => shareModule.provideSharePlus());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.provideSecureStorage(),
    );
    gh.lazySingleton<_i895.Connectivity>(
      () => pluginsModule.provideConnectivity(),
    );
    gh.lazySingleton<_i706.Uuid>(() => pluginsModule.provideUuid());
    gh.lazySingleton<_i297.AuthLocalDataSource>(
      () => _i297.SecureStorageAuthDataSource(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i332.NotificationsService>(
      () => _i332.NotificationsService(
        gh<_i163.FlutterLocalNotificationsPlugin>(),
        gh<_i213.PermissionService>(),
      ),
    );
    gh.lazySingleton<_i735.ImagePickerService>(
      () => _i735.ImagePickerService(gh<_i183.ImagePicker>()),
    );
    gh.lazySingleton<_i580.ShareService>(
      () => _i580.ShareService(gh<_i998.SharePlus>()),
    );
    gh.lazySingleton<_i838.AnalyticsService>(
      () => _i838.FirebaseAnalyticsService(gh<_i398.FirebaseAnalytics>()),
    );
    gh.lazySingleton<_i652.ThemeBloc>(
      () => _i652.ThemeBloc(
        gh<_i460.SharedPreferences>(),
        gh<_i838.AnalyticsService>(),
      ),
    );
    gh.singleton<_i831.Store>(
      () => objectBoxModule.provideStore(gh<_i319.ObjectBox>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.providePlainDio(gh<_i689.EnvConfig>()),
      instanceName: 'plain',
    );
    gh.lazySingleton<_i724.BookmarksLocalDataSource>(
      () => _i724.ObjectBoxBookmarksDataSource(gh<_i831.Store>()),
    );
    gh.lazySingleton<_i529.FirebaseMessagingService>(
      () => _i529.FirebaseMessagingService(
        gh<_i332.NotificationsService>(),
        gh<_i892.FirebaseMessaging>(),
        gh<_i838.AnalyticsService>(),
      ),
    );
    gh.lazySingleton<_i873.AnalyticsRouteObserver>(
      () => _i873.AnalyticsRouteObserver(gh<_i838.AnalyticsService>()),
    );
    gh.lazySingleton<_i533.TokenRefresher>(
      () => _i533.TokenRefresher(
        gh<_i297.AuthLocalDataSource>(),
        gh<_i361.Dio>(instanceName: 'plain'),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => authNetworkModule.provideDio(
        gh<_i297.AuthLocalDataSource>(),
        gh<_i533.TokenRefresher>(),
        gh<_i689.EnvConfig>(),
      ),
    );
    gh.lazySingleton<_i87.AuthRemoteDataSource>(
      () => authNetworkModule.provideAuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i729.BookmarksRemoteDataSource>(
      () => bookmarksRemoteModule.provideBookmarksRemoteDataSource(
        gh<_i361.Dio>(),
      ),
    );
    gh.lazySingleton<_i627.BookmarksSyncController>(
      () => _i539.BookmarksSyncService(
        gh<_i724.BookmarksLocalDataSource>(),
        gh<_i729.BookmarksRemoteDataSource>(),
        gh<_i895.Connectivity>(),
      ),
    );
    gh.lazySingleton<_i987.AuthRepository>(
      () => _i1028.AuthRepositoryImpl(
        gh<_i87.AuthRemoteDataSource>(),
        gh<_i297.AuthLocalDataSource>(),
        gh<_i533.TokenRefresher>(),
      ),
    );
    gh.factory<_i780.ChangePassword>(
      () => _i780.ChangePassword(gh<_i987.AuthRepository>()),
    );
    gh.factory<_i699.Register>(
      () => _i699.Register(gh<_i987.AuthRepository>()),
    );
    gh.factory<_i271.RestoreSession>(
      () => _i271.RestoreSession(gh<_i987.AuthRepository>()),
    );
    gh.factory<_i1001.SignIn>(() => _i1001.SignIn(gh<_i987.AuthRepository>()));
    gh.factory<_i926.SignOut>(() => _i926.SignOut(gh<_i987.AuthRepository>()));
    gh.lazySingleton<_i630.BookmarksRepository>(
      () => _i73.BookmarksRepositoryImpl(
        gh<_i724.BookmarksLocalDataSource>(),
        gh<_i627.BookmarksSyncController>(),
        gh<_i706.Uuid>(),
      ),
    );
    gh.factory<_i11.ChangePasswordCubit>(
      () => _i11.ChangePasswordCubit(gh<_i780.ChangePassword>()),
    );
    gh.lazySingleton<_i269.AuthBloc>(
      () => _i269.AuthBloc(
        signIn: gh<_i1001.SignIn>(),
        register: gh<_i699.Register>(),
        signOut: gh<_i926.SignOut>(),
        restoreSession: gh<_i271.RestoreSession>(),
        analytics: gh<_i838.AnalyticsService>(),
      ),
    );
    gh.factory<_i632.CreateBookmark>(
      () => _i632.CreateBookmark(gh<_i630.BookmarksRepository>()),
    );
    gh.factory<_i244.DeleteBookmark>(
      () => _i244.DeleteBookmark(gh<_i630.BookmarksRepository>()),
    );
    gh.factory<_i690.GetBookmark>(
      () => _i690.GetBookmark(gh<_i630.BookmarksRepository>()),
    );
    gh.factory<_i568.ListBookmarks>(
      () => _i568.ListBookmarks(gh<_i630.BookmarksRepository>()),
    );
    gh.factory<_i412.UpdateBookmark>(
      () => _i412.UpdateBookmark(gh<_i630.BookmarksRepository>()),
    );
    gh.factory<_i373.BookmarkDetailBloc>(
      () => _i373.BookmarkDetailBloc(
        gh<_i690.GetBookmark>(),
        gh<_i244.DeleteBookmark>(),
        gh<_i838.AnalyticsService>(),
      ),
    );
    gh.factory<_i540.BookmarkFormBloc>(
      () => _i540.BookmarkFormBloc(
        gh<_i690.GetBookmark>(),
        gh<_i632.CreateBookmark>(),
        gh<_i412.UpdateBookmark>(),
        gh<_i838.AnalyticsService>(),
        gh<_i735.ImagePickerService>(),
        gh<_i213.PermissionService>(),
      ),
    );
    gh.factory<_i423.HomeBloc>(() => _i423.HomeBloc(gh<_i568.ListBookmarks>()));
    gh.factory<_i566.BookmarksListBloc>(
      () => _i566.BookmarksListBloc(
        gh<_i568.ListBookmarks>(),
        gh<_i244.DeleteBookmark>(),
        gh<_i627.BookmarksSyncController>(),
        gh<_i838.AnalyticsService>(),
      ),
    );
    return this;
  }
}

class _$SharedPreferencesModule extends _i652.SharedPreferencesModule {}

class _$ObjectBoxModule extends _i319.ObjectBoxModule {}

class _$AnalyticsModule extends _i720.AnalyticsModule {}

class _$MediaModule extends _i773.MediaModule {}

class _$NotificationsModule extends _i146.NotificationsModule {}

class _$ShareModule extends _i390.ShareModule {}

class _$SecureStorageModule extends _i297.SecureStorageModule {}

class _$PluginsModule extends _i319.PluginsModule {}

class _$NetworkModule extends _i173.NetworkModule {}

class _$AuthNetworkModule extends _i740.AuthNetworkModule {}

class _$BookmarksRemoteModule extends _i235.BookmarksRemoteModule {}

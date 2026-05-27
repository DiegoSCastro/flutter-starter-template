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
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:flutter_starter_template/core/network/network_module.dart'
    as _i173;
import 'package:flutter_starter_template/core/network/token_refresher.dart'
    as _i665;
import 'package:flutter_starter_template/core/notifications/notifications_module.dart'
    as _i146;
import 'package:flutter_starter_template/core/notifications/notifications_service.dart'
    as _i332;
import 'package:flutter_starter_template/core/theme/theme_cubit.dart' as _i848;
import 'package:flutter_starter_template/features/auth/data/datasources/auth_local_data_source.dart'
    as _i297;
import 'package:flutter_starter_template/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i87;
import 'package:flutter_starter_template/features/auth/data/repositories/auth_repository_impl.dart'
    as _i1028;
import 'package:flutter_starter_template/features/auth/domain/repositories/auth_repository.dart'
    as _i987;
import 'package:flutter_starter_template/features/auth/domain/usecases/restore_session.dart'
    as _i271;
import 'package:flutter_starter_template/features/auth/domain/usecases/sign_in.dart'
    as _i1001;
import 'package:flutter_starter_template/features/auth/domain/usecases/sign_out.dart'
    as _i926;
import 'package:flutter_starter_template/features/auth/presentation/cubit/auth_cubit.dart'
    as _i867;
import 'package:flutter_starter_template/features/bookmarks/data/datasources/bookmarks_remote_data_source.dart'
    as _i729;
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
import 'package:flutter_starter_template/features/bookmarks/presentation/cubit/bookmark_detail_cubit.dart'
    as _i242;
import 'package:flutter_starter_template/features/bookmarks/presentation/cubit/bookmark_form_cubit.dart'
    as _i947;
import 'package:flutter_starter_template/features/bookmarks/presentation/cubit/bookmarks_list_cubit.dart'
    as _i241;
import 'package:flutter_starter_template/objectbox.g.dart' as _i831;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
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
    final notificationsModule = _$NotificationsModule();
    final secureStorageModule = _$SecureStorageModule();
    final pluginsModule = _$PluginsModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.provideSharedPreferences(),
      preResolve: true,
    );
    await gh.singletonAsync<_i319.ObjectBox>(
      () => objectBoxModule.provideObjectBox(),
      preResolve: true,
    );
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => notificationsModule.providePlugin(),
    );
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
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.providePlainDio(),
      instanceName: 'plain',
    );
    gh.lazySingleton<_i848.ThemeCubit>(
      () => _i848.ThemeCubit(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i332.NotificationsService>(
      () => _i332.NotificationsService(
        gh<_i163.FlutterLocalNotificationsPlugin>(),
      ),
    );
    gh.lazySingleton<_i665.TokenRefresher>(
      () => _i665.TokenRefresher(
        gh<_i297.AuthLocalDataSource>(),
        gh<_i361.Dio>(instanceName: 'plain'),
      ),
    );
    gh.singleton<_i831.Store>(
      () => objectBoxModule.provideStore(gh<_i319.ObjectBox>()),
    );
    gh.lazySingleton<_i724.BookmarksLocalDataSource>(
      () => _i724.ObjectBoxBookmarksDataSource(gh<_i831.Store>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.provideDio(
        gh<_i297.AuthLocalDataSource>(),
        gh<_i665.TokenRefresher>(),
      ),
    );
    gh.lazySingleton<_i87.AuthRemoteDataSource>(
      () => networkModule.provideAuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i729.BookmarksRemoteDataSource>(
      () => networkModule.provideBookmarksRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i987.AuthRepository>(
      () => _i1028.AuthRepositoryImpl(
        gh<_i87.AuthRemoteDataSource>(),
        gh<_i297.AuthLocalDataSource>(),
        gh<_i665.TokenRefresher>(),
      ),
    );
    gh.lazySingleton<_i539.BookmarksSyncService>(
      () => _i539.BookmarksSyncService(
        gh<_i724.BookmarksLocalDataSource>(),
        gh<_i729.BookmarksRemoteDataSource>(),
        gh<_i895.Connectivity>(),
      ),
    );
    gh.lazySingleton<_i630.BookmarksRepository>(
      () => _i73.BookmarksRepositoryImpl(
        gh<_i724.BookmarksLocalDataSource>(),
        gh<_i539.BookmarksSyncService>(),
        gh<_i706.Uuid>(),
      ),
    );
    gh.factory<_i271.RestoreSession>(
      () => _i271.RestoreSession(gh<_i987.AuthRepository>()),
    );
    gh.factory<_i1001.SignIn>(() => _i1001.SignIn(gh<_i987.AuthRepository>()));
    gh.factory<_i926.SignOut>(() => _i926.SignOut(gh<_i987.AuthRepository>()));
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
    gh.lazySingleton<_i867.AuthCubit>(
      () => _i867.AuthCubit(
        signIn: gh<_i1001.SignIn>(),
        signOut: gh<_i926.SignOut>(),
        restoreSession: gh<_i271.RestoreSession>(),
      ),
    );
    gh.lazySingleton<_i241.BookmarksListCubit>(
      () => _i241.BookmarksListCubit(
        gh<_i568.ListBookmarks>(),
        gh<_i244.DeleteBookmark>(),
        gh<_i539.BookmarksSyncService>(),
      ),
    );
    gh.factory<_i242.BookmarkDetailCubit>(
      () => _i242.BookmarkDetailCubit(
        gh<_i690.GetBookmark>(),
        gh<_i244.DeleteBookmark>(),
      ),
    );
    gh.factory<_i947.BookmarkFormCubit>(
      () => _i947.BookmarkFormCubit(
        gh<_i690.GetBookmark>(),
        gh<_i632.CreateBookmark>(),
        gh<_i412.UpdateBookmark>(),
      ),
    );
    return this;
  }
}

class _$SharedPreferencesModule extends _i848.SharedPreferencesModule {}

class _$ObjectBoxModule extends _i319.ObjectBoxModule {}

class _$NotificationsModule extends _i146.NotificationsModule {}

class _$SecureStorageModule extends _i297.SecureStorageModule {}

class _$PluginsModule extends _i319.PluginsModule {}

class _$NetworkModule extends _i173.NetworkModule {}

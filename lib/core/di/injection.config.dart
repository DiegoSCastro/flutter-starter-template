// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:flutter_starter_template/core/network/network_module.dart'
    as _i173;
import 'package:flutter_starter_template/core/network/token_refresher.dart'
    as _i665;
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
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final secureStorageModule = _$SecureStorageModule();
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.provideSecureStorage(),
    );
    gh.lazySingleton<_i297.AuthLocalDataSource>(
      () => _i297.SecureStorageAuthDataSource(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.providePlainDio(),
      instanceName: 'plain',
    );
    gh.lazySingleton<_i665.TokenRefresher>(
      () => _i665.TokenRefresher(
        gh<_i297.AuthLocalDataSource>(),
        gh<_i361.Dio>(instanceName: 'plain'),
      ),
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
    gh.lazySingleton<_i987.AuthRepository>(
      () => _i1028.AuthRepositoryImpl(
        gh<_i87.AuthRemoteDataSource>(),
        gh<_i297.AuthLocalDataSource>(),
        gh<_i665.TokenRefresher>(),
      ),
    );
    gh.factory<_i271.RestoreSession>(
      () => _i271.RestoreSession(gh<_i987.AuthRepository>()),
    );
    gh.factory<_i1001.SignIn>(() => _i1001.SignIn(gh<_i987.AuthRepository>()));
    gh.factory<_i926.SignOut>(() => _i926.SignOut(gh<_i987.AuthRepository>()));
    gh.lazySingleton<_i867.AuthCubit>(
      () => _i867.AuthCubit(
        signIn: gh<_i1001.SignIn>(),
        signOut: gh<_i926.SignOut>(),
        restoreSession: gh<_i271.RestoreSession>(),
      ),
    );
    return this;
  }
}

class _$SecureStorageModule extends _i297.SecureStorageModule {}

class _$NetworkModule extends _i173.NetworkModule {}

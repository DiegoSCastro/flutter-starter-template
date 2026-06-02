// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:config/src/env_config.dart' as _i607;
import 'package:config/src/remote_config_module.dart' as _i320;
import 'package:config/src/remote_config_service.dart' as _i346;
import 'package:firebase_remote_config/firebase_remote_config.dart' as _i627;
import 'package:injectable/injectable.dart' as _i526;

class CoreConfigPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final remoteConfigModule = _$RemoteConfigModule();
    gh.singleton<_i607.EnvConfig>(() => const _i607.EnvConfig());
    gh.lazySingleton<_i627.FirebaseRemoteConfig>(
      () => remoteConfigModule.provideRemoteConfig(),
    );
    gh.lazySingleton<_i346.RemoteConfigService>(
      () => _i346.FirebaseRemoteConfigService(gh<_i627.FirebaseRemoteConfig>()),
    );
  }
}

class _$RemoteConfigModule extends _i320.RemoteConfigModule {}

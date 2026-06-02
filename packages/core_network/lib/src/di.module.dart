// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:core_config/core_config.dart' as _i277;
import 'package:core_network/src/network_module.dart' as _i699;
import 'package:core_network/src/performance_module.dart' as _i762;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_performance/firebase_performance.dart' as _i346;
import 'package:injectable/injectable.dart' as _i526;

class CoreNetworkPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final performanceModule = _$PerformanceModule();
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i346.FirebasePerformance>(
      () => performanceModule.providePerformance(),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.providePlainDio(gh<_i277.EnvConfig>()),
      instanceName: 'plain',
    );
  }
}

class _$PerformanceModule extends _i762.PerformanceModule {}

class _$NetworkModule extends _i699.NetworkModule {}

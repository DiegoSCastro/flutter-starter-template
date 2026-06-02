// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:core_storage/src/keychain_reset_on_reinstall.dart' as _i263;
import 'package:core_storage/src/shared_preferences_module.dart' as _i491;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

class CoreStoragePackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) async {
    final sharedPreferencesModule = _$SharedPreferencesModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.provideSharedPreferences(),
      preResolve: true,
    );
    gh.lazySingleton<_i263.KeychainResetOnReinstall>(
        () => _i263.KeychainResetOnReinstall(
              gh<_i460.SharedPreferences>(),
              gh<_i558.FlutterSecureStorage>(),
            ));
  }
}

class _$SharedPreferencesModule extends _i491.SharedPreferencesModule {}

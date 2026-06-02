// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:analytics/analytics.dart' as _i682;
import 'package:theme/src/theme_bloc.dart' as _i946;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

class CoreThemePackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.lazySingleton<_i946.ThemeBloc>(
      () => _i946.ThemeBloc(
        gh<_i460.SharedPreferences>(),
        gh<_i682.AnalyticsService>(),
      ),
    );
  }
}

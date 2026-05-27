import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_state.dart';

const _kThemeModeKey = 'app.theme_mode';
const _kThemeSchemeKey = 'app.theme_scheme';

@lazySingleton
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._prefs) : super(_readInitial(_prefs));

  final SharedPreferences _prefs;

  static ThemeState _readInitial(SharedPreferences prefs) {
    final modeRaw = prefs.getString(_kThemeModeKey);
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == modeRaw,
      orElse: () => ThemeMode.system,
    );

    final schemeRaw = prefs.getString(_kThemeSchemeKey);
    final scheme = FlexScheme.values.firstWhere(
      (s) => s.name == schemeRaw,
      orElse: () => ThemeState.defaultScheme,
    );

    return ThemeState(mode: mode, scheme: scheme);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == state.mode) return;
    final next = state.copyWith(mode: mode);
    await _persistAndEmit(next);
  }

  Future<void> setScheme(FlexScheme scheme) async {
    if (scheme == state.scheme) return;
    final next = state.copyWith(scheme: scheme);
    await _persistAndEmit(next);
  }

  Future<void> _persistAndEmit(ThemeState next) async {
    emit(next);
    await _prefs.setString(_kThemeModeKey, next.mode.name);
    await _prefs.setString(_kThemeSchemeKey, next.scheme.name);
  }
}

@module
abstract class SharedPreferencesModule {
  @preResolve
  Future<SharedPreferences> provideSharedPreferences() =>
      SharedPreferences.getInstance();
}

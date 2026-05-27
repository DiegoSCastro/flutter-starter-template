import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'app.theme_mode';

/// Holds the active [ThemeMode] and persists user overrides so the choice
/// survives app restarts. Defaults to [ThemeMode.system] on first launch.
@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_readInitial(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _readInitial(SharedPreferences prefs) {
    final raw = prefs.getString(_kThemeModeKey);
    return ThemeMode.values
        .firstWhere((m) => m.name == raw, orElse: () => ThemeMode.system);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _prefs.setString(_kThemeModeKey, mode.name);
  }

  Future<void> toggle() async {
    final next = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    await setMode(next);
  }
}

@module
abstract class SharedPreferencesModule {
  @preResolve
  Future<SharedPreferences> provideSharedPreferences() =>
      SharedPreferences.getInstance();
}

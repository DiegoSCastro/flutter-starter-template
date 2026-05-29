import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/analytics_extensions.dart';
import '../analytics/analytics_service.dart';
import 'theme_state.dart';

part 'theme_event.dart';

const _kThemeModeKey = 'app.theme_mode';
const _kThemeSchemeKey = 'app.theme_scheme';

@lazySingleton
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(this._prefs, this._analytics) : super(_readInitial(_prefs)) {
    on<ThemeModeChanged>(_onModeChanged, transformer: sequential());
    on<ThemeSchemeChanged>(_onSchemeChanged, transformer: sequential());
  }

  final SharedPreferences _prefs;
  final AnalyticsService _analytics;

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

  Future<void> _onModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      if (event.mode == state.mode) {
        return;
      }
      final next = state.copyWith(mode: event.mode);
      emit(next);
      await _persist(next);
      unawaited(_analytics.trackThemeModeChanged(event.mode.name));
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _onSchemeChanged(
    ThemeSchemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      if (event.scheme == state.scheme) {
        return;
      }
      final next = state.copyWith(scheme: event.scheme);
      emit(next);
      await _persist(next);
      unawaited(_analytics.trackThemeSchemeChanged(event.scheme.name));
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _persist(ThemeState next) async {
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

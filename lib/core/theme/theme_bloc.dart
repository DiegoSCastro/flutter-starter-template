import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/analytics_extensions.dart';
import '../analytics/analytics_service.dart';
import '../bloc/event_completion.dart';
import 'theme_state.dart';

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

  Future<void> setMode(ThemeMode mode) {
    if (mode == state.mode) return Future<void>.value();
    final completer = Completer<void>();
    add(ThemeModeChanged(mode, completer: completer));
    return completer.future;
  }

  Future<void> setScheme(FlexScheme scheme) {
    if (scheme == state.scheme) return Future<void>.value();
    final completer = Completer<void>();
    add(ThemeSchemeChanged(scheme, completer: completer));
    return completer.future;
  }

  Future<void> _onModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      if (event.mode == state.mode) {
        event.completer.completeVoidIfPending();
        return;
      }
      final next = state.copyWith(mode: event.mode);
      emit(next);
      await _persist(next);
      unawaited(_analytics.trackThemeModeChanged(event.mode.name));
      event.completer.completeVoidIfPending();
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }

  Future<void> _onSchemeChanged(
    ThemeSchemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      if (event.scheme == state.scheme) {
        event.completer.completeVoidIfPending();
        return;
      }
      final next = state.copyWith(scheme: event.scheme);
      emit(next);
      await _persist(next);
      unawaited(_analytics.trackThemeSchemeChanged(event.scheme.name));
      event.completer.completeVoidIfPending();
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }

  Future<void> _persist(ThemeState next) async {
    await _prefs.setString(_kThemeModeKey, next.mode.name);
    await _prefs.setString(_kThemeSchemeKey, next.scheme.name);
  }
}

sealed class ThemeEvent {
  const ThemeEvent();
}

final class ThemeModeChanged extends ThemeEvent {
  const ThemeModeChanged(this.mode, {this.completer});

  final ThemeMode mode;
  final Completer<void>? completer;
}

final class ThemeSchemeChanged extends ThemeEvent {
  const ThemeSchemeChanged(this.scheme, {this.completer});

  final FlexScheme scheme;
  final Completer<void>? completer;
}

@module
abstract class SharedPreferencesModule {
  @preResolve
  Future<SharedPreferences> provideSharedPreferences() =>
      SharedPreferences.getInstance();
}

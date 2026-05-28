import 'package:bloc_test/bloc_test.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/core/theme/theme_cubit.dart';
import 'package:flutter_starter_template/core/theme/theme_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_utils.dart';

void main() {
  late MockSharedPreferences mockPrefs;
  late ThemeCubit cubit;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    registerFallbackValue('');
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    cubit = ThemeCubit(mockPrefs);
  });

  tearDown(() {
    cubit.close();
  });

  group('ThemeCubit', () {
    test('initial state has default scheme and system mode when no prefs', () {
      expect(cubit.state.mode, ThemeMode.system);
      expect(cubit.state.scheme, ThemeState.defaultScheme);
    });

    test('reads initial state from SharedPreferences', () {
      when(() => mockPrefs.getString('app.theme_mode')).thenReturn('dark');
      when(() => mockPrefs.getString('app.theme_scheme')).thenReturn('indigo');

      final c = ThemeCubit(mockPrefs);
      expect(c.state.mode, ThemeMode.dark);
      expect(c.state.scheme, FlexScheme.indigo);
      c.close();
    });

    group('setMode', () {
      blocTest<ThemeCubit, ThemeState>(
        'emits new mode and persists to prefs',
        build: () => cubit,
        act: (cubit) => cubit.setMode(ThemeMode.dark),
        expect: () => [
          predicate<ThemeState>(
            (s) =>
                s.mode == ThemeMode.dark &&
                s.scheme == ThemeState.defaultScheme,
          ),
        ],
        verify: (_) {
          verify(() => mockPrefs.setString('app.theme_mode', 'dark')).called(1);
          verify(
            () => mockPrefs.setString(
              'app.theme_scheme',
              ThemeState.defaultScheme.name,
            ),
          ).called(1);
        },
      );

      blocTest<ThemeCubit, ThemeState>(
        'does nothing when mode is unchanged',
        build: () => cubit,
        act: (cubit) => cubit.setMode(ThemeMode.system),
        expect: () => <ThemeState>[],
      );
    });

    group('setScheme', () {
      blocTest<ThemeCubit, ThemeState>(
        'emits new scheme and persists to prefs',
        build: () => cubit,
        act: (cubit) => cubit.setScheme(FlexScheme.mango),
        expect: () => [
          predicate<ThemeState>(
            (s) => s.mode == ThemeMode.system && s.scheme == FlexScheme.mango,
          ),
        ],
        verify: (_) {
          verify(
            () => mockPrefs.setString('app.theme_mode', 'system'),
          ).called(1);
          verify(
            () => mockPrefs.setString('app.theme_scheme', 'mango'),
          ).called(1);
        },
      );

      blocTest<ThemeCubit, ThemeState>(
        'does nothing when scheme is unchanged',
        build: () => cubit,
        act: (cubit) => cubit.setScheme(ThemeState.defaultScheme),
        expect: () => <ThemeState>[],
      );
    });
  });
}

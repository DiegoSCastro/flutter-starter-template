part of 'theme_bloc.dart';

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

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/theme/semantic_colors.dart';

extension BuildContextTheme on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  /// App-defined status colors (success / warning / info) registered on the
  /// theme. Falls back to [SemanticColors.light] if the extension is missing.
  SemanticColors get semanticColors =>
      theme.extension<SemanticColors>() ?? SemanticColors.light;
  Brightness get brightness => theme.brightness;
  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;
}

extension BuildContextMedia on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  EdgeInsets get viewPadding => mediaQuery.viewPadding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  double get bottomInset => mediaQuery.viewInsets.bottom;
  Orientation get orientation => mediaQuery.orientation;
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;
}

extension BuildContextLocalization on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'semantic_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light({FlexScheme scheme = FlexScheme.blue}) {
    return FlexThemeData.light(
      scheme: scheme,
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
    ).copyWith(
      extensions: const [SemanticColors.light],
    );
  }

  static ThemeData dark({FlexScheme scheme = FlexScheme.blue}) {
    return FlexThemeData.dark(
      scheme: scheme,
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
    ).copyWith(
      extensions: const [SemanticColors.dark],
    );
  }
}

extension BuildContextTheme on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  SemanticColors get semanticColors =>
      theme.extension<SemanticColors>() ?? SemanticColors.light;
  Brightness get brightness => theme.brightness;
  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;
}

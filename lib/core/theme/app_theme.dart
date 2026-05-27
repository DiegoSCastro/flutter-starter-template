import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme_state.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light({FlexScheme scheme = ThemeState.defaultScheme}) {
    return FlexThemeData.light(
      scheme: scheme,
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
    );
  }

  static ThemeData dark({FlexScheme scheme = ThemeState.defaultScheme}) {
    return FlexThemeData.dark(
      scheme: scheme,
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
    );
  }
}

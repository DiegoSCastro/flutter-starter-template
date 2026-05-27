import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return FlexThemeData.light(
      scheme: FlexScheme.deepPurple,
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return FlexThemeData.dark(
      scheme: FlexScheme.deepPurple,
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
    );
  }
}

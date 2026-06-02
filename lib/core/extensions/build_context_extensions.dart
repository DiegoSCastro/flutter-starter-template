import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';


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

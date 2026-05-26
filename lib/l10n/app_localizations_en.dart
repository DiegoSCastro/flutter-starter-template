// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Starter';

  @override
  String get loginAppBarTitle => 'Sign in';

  @override
  String get loginHeadline => 'Welcome back';

  @override
  String get loginUsernameLabel => 'Username';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get fieldRequired => 'Required';

  @override
  String get errorInvalidCredentials => 'Please enter a username and password.';

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String get homeAppBarTitle => 'Home';

  @override
  String get homeSignOutTooltip => 'Sign out';

  @override
  String homeWelcome(String username) {
    return 'Welcome, $username!';
  }

  @override
  String get homeSignedInBody => 'You are signed in.';
}

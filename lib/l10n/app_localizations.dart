import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Starter'**
  String get appTitle;

  /// No description provided for @loginAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginAppBarTitle;

  /// No description provided for @loginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginHeadline;

  /// No description provided for @loginUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get loginUsernameLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmit;

  /// No description provided for @loginNavigateToRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register here'**
  String get loginNavigateToRegister;

  /// No description provided for @registerAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerAppBarTitle;

  /// No description provided for @registerHeadline.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get registerHeadline;

  /// No description provided for @registerUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get registerUsernameLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerSubmit;

  /// No description provided for @errorPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorPasswordsDoNotMatch;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username and password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input.'**
  String get errorInvalidInput;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnknown;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonImageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get commonImageLoadFailed;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get commonSignOut;

  /// No description provided for @homeAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeAppBarTitle;

  /// No description provided for @homeSignOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get homeSignOutTooltip;

  /// No description provided for @homeMyBookmarks.
  ///
  /// In en, this message translates to:
  /// **'My bookmarks'**
  String get homeMyBookmarks;

  /// No description provided for @homeNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get homeNoDescription;

  /// No description provided for @homeProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeProfileTooltip;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {username}!'**
  String homeWelcome(String username);

  /// No description provided for @homeSignedInBody.
  ///
  /// In en, this message translates to:
  /// **'You are signed in.'**
  String get homeSignedInBody;

  /// No description provided for @homeRecentBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Recent Bookmarks'**
  String get homeRecentBookmarks;

  /// No description provided for @homeNoBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet. Tap + to add one.'**
  String get homeNoBookmarks;

  /// No description provided for @homeStatsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get homeStatsTotal;

  /// No description provided for @homeStatsRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homeStatsRecent;

  /// No description provided for @homeStatsTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get homeStatsTags;

  /// No description provided for @profileAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileAppBarTitle;

  /// No description provided for @profileSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileSectionAppearance;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePassword;

  /// No description provided for @changePasswordAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordAppBarTitle;

  /// No description provided for @changePasswordCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get changePasswordCurrentLabel;

  /// No description provided for @changePasswordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePasswordNewLabel;

  /// No description provided for @changePasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get changePasswordConfirmLabel;

  /// No description provided for @changePasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get changePasswordSubmit;

  /// No description provided for @changePasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get changePasswordSuccessMessage;

  /// No description provided for @changePasswordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match.'**
  String get changePasswordMismatchError;

  /// No description provided for @profileSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileSectionAbout;

  /// No description provided for @profileUserIdCopied.
  ///
  /// In en, this message translates to:
  /// **'User ID copied'**
  String get profileUserIdCopied;

  /// No description provided for @profileThemeSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get profileThemeSystemDefault;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileAppVersionBuild.
  ///
  /// In en, this message translates to:
  /// **'Version {version} (build {buildNumber})'**
  String profileAppVersionBuild(String version, String buildNumber);

  /// No description provided for @profileSignOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileSignOutConfirmMessage;

  /// No description provided for @bookmarksAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksAppBarTitle;

  /// No description provided for @bookmarksSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search title, URL, or tag'**
  String get bookmarksSearchHint;

  /// No description provided for @bookmarksNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get bookmarksNoMatchesTitle;

  /// No description provided for @bookmarksNoMatchesMessage.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks match your search.'**
  String get bookmarksNoMatchesMessage;

  /// No description provided for @bookmarksEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get bookmarksEmptyTitle;

  /// No description provided for @bookmarksEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first bookmark.'**
  String get bookmarksEmptyMessage;

  /// No description provided for @bookmarksNotYetSynced.
  ///
  /// In en, this message translates to:
  /// **'Not yet synced'**
  String get bookmarksNotYetSynced;

  /// No description provided for @bookmarksSyncFailedRetryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sync failed - tap to retry'**
  String get bookmarksSyncFailedRetryTooltip;

  /// No description provided for @bookmarkAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmarkAppBarTitle;

  /// No description provided for @bookmarkNotFound.
  ///
  /// In en, this message translates to:
  /// **'Bookmark not found.'**
  String get bookmarkNotFound;

  /// No description provided for @bookmarkDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete bookmark?'**
  String get bookmarkDeleteDialogTitle;

  /// No description provided for @bookmarkDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed.'**
  String bookmarkDeleteDialogMessage(String title);

  /// No description provided for @bookmarkOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Open URL'**
  String get bookmarkOpenUrl;

  /// No description provided for @bookmarkInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get bookmarkInvalidUrl;

  /// No description provided for @bookmarkCouldNotOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not open URL'**
  String get bookmarkCouldNotOpenUrl;

  /// No description provided for @bookmarkFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit bookmark'**
  String get bookmarkFormEditTitle;

  /// No description provided for @bookmarkFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New bookmark'**
  String get bookmarkFormNewTitle;

  /// No description provided for @bookmarkFormLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load bookmark.'**
  String get bookmarkFormLoadFailed;

  /// No description provided for @bookmarkTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get bookmarkTitleLabel;

  /// No description provided for @bookmarkUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get bookmarkUrlLabel;

  /// No description provided for @bookmarkDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get bookmarkDescriptionLabel;

  /// No description provided for @bookmarkTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get bookmarkTagsLabel;

  /// No description provided for @bookmarkTagsHint.
  ///
  /// In en, this message translates to:
  /// **'comma, separated, values'**
  String get bookmarkTagsHint;

  /// No description provided for @bookmarkTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get bookmarkTitleRequired;

  /// No description provided for @bookmarkUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'URL is required'**
  String get bookmarkUrlRequired;

  /// No description provided for @bookmarkUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL (https://…)'**
  String get bookmarkUrlInvalid;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

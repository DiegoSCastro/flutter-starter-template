// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Flutter Starter';

  @override
  String get loginAppBarTitle => 'Đăng nhập';

  @override
  String get loginHeadline => 'Chào mừng trở lại';

  @override
  String get loginUsernameLabel => 'Tên đăng nhập';

  @override
  String get loginPasswordLabel => 'Mật khẩu';

  @override
  String get loginSubmit => 'Đăng nhập';

  @override
  String get fieldRequired => 'Bắt buộc';

  @override
  String get errorInvalidCredentials =>
      'Vui lòng nhập tên đăng nhập và mật khẩu.';

  @override
  String get errorUnknown => 'Đã xảy ra lỗi.';

  @override
  String get homeAppBarTitle => 'Trang chủ';

  @override
  String get homeSignOutTooltip => 'Đăng xuất';

  @override
  String homeWelcome(String username) {
    return 'Chào, $username!';
  }

  @override
  String get homeSignedInBody => 'Bạn đã đăng nhập.';
}

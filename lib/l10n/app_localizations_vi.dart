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
  String get loginNavigateToRegister => 'Chưa có tài khoản? Đăng ký ngay';

  @override
  String get registerAppBarTitle => 'Đăng ký';

  @override
  String get registerHeadline => 'Tạo tài khoản mới';

  @override
  String get registerUsernameLabel => 'Tên đăng nhập';

  @override
  String get registerPasswordLabel => 'Mật khẩu';

  @override
  String get registerConfirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get registerSubmit => 'Đăng ký';

  @override
  String get errorPasswordsDoNotMatch => 'Mật khẩu không khớp.';

  @override
  String get fieldRequired => 'Bắt buộc';

  @override
  String get errorInvalidCredentials =>
      'Vui lòng nhập tên đăng nhập và mật khẩu.';

  @override
  String get errorInvalidInput => 'Dữ liệu không hợp lệ.';

  @override
  String get errorUnknown => 'Đã xảy ra lỗi.';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonCreate => 'Tạo';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get commonEdit => 'Chỉnh sửa';

  @override
  String get commonImageLoadFailed => 'Không tải được hình ảnh';

  @override
  String get commonLoading => 'Đang tải…';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonShare => 'Chia sẻ';

  @override
  String get commonSignOut => 'Đăng xuất';

  @override
  String get homeAppBarTitle => 'Trang chủ';

  @override
  String get homeSignOutTooltip => 'Đăng xuất';

  @override
  String get homeMyBookmarks => 'Bookmark của tôi';

  @override
  String get homeNoDescription => 'Không có mô tả';

  @override
  String get homeProfileTooltip => 'Hồ sơ';

  @override
  String homeWelcome(String username) {
    return 'Chào, $username!';
  }

  @override
  String get homeSignedInBody => 'Bạn đã đăng nhập.';

  @override
  String get homeRecentBookmarks => 'Bookmark gần đây';

  @override
  String get homeNoBookmarks => 'Chưa có bookmark nào. Nhấn + để thêm.';

  @override
  String get homeStatsTotal => 'Tổng cộng';

  @override
  String get homeStatsRecent => 'Gần đây';

  @override
  String get homeStatsTags => 'Thẻ';

  @override
  String get profileAppBarTitle => 'Hồ sơ';

  @override
  String get profileSectionAppearance => 'Giao diện';

  @override
  String get profileSectionAccount => 'Tài khoản';

  @override
  String get profileChangePassword => 'Đổi mật khẩu';

  @override
  String get changePasswordAppBarTitle => 'Đổi mật khẩu';

  @override
  String get changePasswordCurrentLabel => 'Mật khẩu hiện tại';

  @override
  String get changePasswordNewLabel => 'Mật khẩu mới';

  @override
  String get changePasswordConfirmLabel => 'Xác nhận mật khẩu mới';

  @override
  String get changePasswordSubmit => 'Cập nhật mật khẩu';

  @override
  String get changePasswordSuccessMessage => 'Cập nhật mật khẩu thành công.';

  @override
  String get changePasswordMismatchError => 'Mật khẩu mới không khớp.';

  @override
  String get profileSectionAbout => 'Giới thiệu';

  @override
  String get profileUserIdCopied => 'Đã sao chép ID người dùng';

  @override
  String get profileThemeSystemDefault => 'Mặc định hệ thống';

  @override
  String get profileThemeLight => 'Sáng';

  @override
  String get profileThemeDark => 'Tối';

  @override
  String profileAppVersionBuild(String version, String buildNumber) {
    return 'Phiên bản $version (bản dựng $buildNumber)';
  }

  @override
  String get profileSignOutConfirmMessage =>
      'Bạn có chắc muốn đăng xuất không?';

  @override
  String get bookmarksAppBarTitle => 'Bookmarks';

  @override
  String get bookmarksSearchHint => 'Tìm tiêu đề, URL hoặc thẻ';

  @override
  String get bookmarksNoMatchesTitle => 'Không có kết quả';

  @override
  String get bookmarksNoMatchesMessage =>
      'Không có bookmark nào khớp với tìm kiếm.';

  @override
  String get bookmarksEmptyTitle => 'Chưa có bookmark nào';

  @override
  String get bookmarksEmptyMessage => 'Nhấn + để thêm bookmark đầu tiên.';

  @override
  String get bookmarksNotYetSynced => 'Chưa đồng bộ';

  @override
  String get bookmarksSyncFailedRetryTooltip =>
      'Đồng bộ thất bại - nhấn để thử lại';

  @override
  String get bookmarkAppBarTitle => 'Bookmark';

  @override
  String get bookmarkNotFound => 'Không tìm thấy bookmark.';

  @override
  String get bookmarkDeleteDialogTitle => 'Xóa bookmark?';

  @override
  String bookmarkDeleteDialogMessage(String title) {
    return '\"$title\" sẽ bị xóa.';
  }

  @override
  String get bookmarkOpenUrl => 'Mở URL';

  @override
  String get bookmarkInvalidUrl => 'URL không hợp lệ';

  @override
  String get bookmarkCouldNotOpenUrl => 'Không thể mở URL';

  @override
  String get bookmarkFormEditTitle => 'Chỉnh sửa bookmark';

  @override
  String get bookmarkFormNewTitle => 'Bookmark mới';

  @override
  String get bookmarkFormLoadFailed => 'Không tải được bookmark.';

  @override
  String get bookmarkTitleLabel => 'Tiêu đề';

  @override
  String get bookmarkUrlLabel => 'URL';

  @override
  String get bookmarkDescriptionLabel => 'Mô tả (tùy chọn)';

  @override
  String get bookmarkTagsLabel => 'Thẻ';

  @override
  String get bookmarkTagsHint => 'các, giá trị, phân tách, bằng, dấu phẩy';

  @override
  String get bookmarkTitleRequired => 'Bắt buộc nhập tiêu đề';

  @override
  String get bookmarkUrlRequired => 'Bắt buộc nhập URL';

  @override
  String get bookmarkUrlInvalid => 'Nhập URL hợp lệ (https://…)';
}

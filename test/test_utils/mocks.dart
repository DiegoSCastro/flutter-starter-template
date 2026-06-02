import 'package:core_analytics/core_analytics.dart';
import 'package:core_platform/core_platform.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_starter_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/delete_account.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/register.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/restore_session.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/sign_in.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/entities/bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmarks_sync_controller.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/create_bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/delete_bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/get_bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/list_bookmarks.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/list_local_bookmarks.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/update_bookmark.dart';
import 'package:flutter_starter_template/shared/domain/bookmark_stats.dart';
import 'package:flutter_starter_template/shared/domain/entities/auth_user.dart';
import 'package:flutter_starter_template/shared/domain/session.dart';
import 'package:mocktail/mocktail.dart';

class MockSignIn extends Mock implements SignIn {}

class MockRegister extends Mock implements Register {}

class MockSignOut extends Mock implements SignOut {}

class MockDeleteAccount extends Mock implements DeleteAccount {}

class MockRestoreSession extends Mock implements RestoreSession {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void stubAnalyticsService(MockAnalyticsService analytics) {
  when(
    () => analytics.logEvent(any(), parameters: any(named: 'parameters')),
  ).thenAnswer((_) async {});
  when(
    () => analytics.logLogin(method: any(named: 'method')),
  ).thenAnswer((_) async {});
  when(
    () => analytics.logSignUp(signUpMethod: any(named: 'signUpMethod')),
  ).thenAnswer((_) async {});
  when(
    () => analytics.logScreenView(screenName: any(named: 'screenName')),
  ).thenAnswer((_) async {});
  when(() => analytics.setCurrentUser(any())).thenAnswer((_) async {});
  when(
    () => analytics.setUserProperty(
      name: any(named: 'name'),
      value: any(named: 'value'),
    ),
  ).thenAnswer((_) async {});
}

class MockListBookmarks extends Mock implements ListBookmarks {}

class MockBookmarkStatsReader extends Mock implements BookmarkStatsReader {}

class MockListLocalBookmarks extends Mock implements ListLocalBookmarks {}

class MockGetBookmark extends Mock implements GetBookmark {}

class MockCreateBookmark extends Mock implements CreateBookmark {}

class MockUpdateBookmark extends Mock implements UpdateBookmark {}

class MockDeleteBookmark extends Mock implements DeleteBookmark {}

class MockBookmarksSyncController extends Mock
    implements BookmarksSyncController {}

class FakeBookmarkInput extends Fake implements BookmarkInput {}

class MockImagePickerService extends Mock implements ImagePickerService {}

class MockPermissionService extends Mock implements PermissionService {}

/// In-memory [Session] double for widget tests.
class FakeSession extends ChangeNotifier implements Session {
  FakeSession({this.currentUser, this.isSigningOut = false});

  @override
  AuthUser? currentUser;

  @override
  bool isSigningOut;

  @override
  Future<void> restore() async {}

  @override
  void signOut() {}

  @override
  void clearSession() {}
}

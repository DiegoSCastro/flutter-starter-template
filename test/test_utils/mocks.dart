import 'package:flutter_starter_template/core/analytics/analytics_service.dart';
import 'package:flutter_starter_template/features/auth/domain/repositories/auth_repository.dart';
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
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/update_bookmark.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSignIn extends Mock implements SignIn {}

class MockRegister extends Mock implements Register {}

class MockSignOut extends Mock implements SignOut {}

class MockRestoreSession extends Mock implements RestoreSession {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

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

class MockGetBookmark extends Mock implements GetBookmark {}

class MockCreateBookmark extends Mock implements CreateBookmark {}

class MockUpdateBookmark extends Mock implements UpdateBookmark {}

class MockDeleteBookmark extends Mock implements DeleteBookmark {}

class MockBookmarksSyncController extends Mock
    implements BookmarksSyncController {}

class FakeBookmarkInput extends Fake implements BookmarkInput {}

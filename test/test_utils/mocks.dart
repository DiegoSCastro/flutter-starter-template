import 'package:flutter_starter_template/features/auth/domain/usecases/restore_session.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/sign_in.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_starter_template/features/bookmarks/data/sync/bookmarks_sync_service.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/repositories/bookmarks_repository.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/create_bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/delete_bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/get_bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/list_bookmarks.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/update_bookmark.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSignIn extends Mock implements SignIn {}

class MockSignOut extends Mock implements SignOut {}

class MockRestoreSession extends Mock implements RestoreSession {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockListBookmarks extends Mock implements ListBookmarks {}

class MockGetBookmark extends Mock implements GetBookmark {}

class MockCreateBookmark extends Mock implements CreateBookmark {}

class MockUpdateBookmark extends Mock implements UpdateBookmark {}

class MockDeleteBookmark extends Mock implements DeleteBookmark {}

class MockBookmarksSyncService extends Mock implements BookmarksSyncService {}

class FakeBookmarkInput extends Fake implements BookmarkInput {}

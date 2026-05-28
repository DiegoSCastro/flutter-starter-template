import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_starter_template/core/di/injection.dart';
import 'package:flutter_starter_template/core/theme/theme_cubit.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_template/app/app.dart';
import 'package:flutter_starter_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmarks_sync_controller.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/cubit/bookmarks_list/bookmarks_list_cubit.dart';
import 'package:flutter_starter_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_utils.dart';

void main() {
  late StreamController<BookmarksSyncStatus> syncStatusController;
  late MockBookmarksSyncController sync;
  late AuthCubit authCubit;
  late ThemeCubit themeCubit;
  late BookmarksListCubit bookmarksCubit;
  late HomeCubit homeCubit;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});

    final signIn = MockSignIn();
    when(
      () => signIn(username: 'alice', password: 'hunter2'),
    ).thenAnswer((_) async => const Ok(testUser));

    final restoreSession = MockRestoreSession();
    when(
      () => restoreSession(),
    ).thenAnswer((_) async => const Err(testFailure));

    final signOut = MockSignOut();
    when(() => signOut()).thenAnswer((_) async => const Ok(null));

    syncStatusController = StreamController<BookmarksSyncStatus>.broadcast();
    sync = MockBookmarksSyncController();
    when(
      () => sync.statusStream,
    ).thenAnswer((_) => syncStatusController.stream);
    when(() => sync.statusNow).thenReturn(BookmarksSyncStatus.idle);
    when(() => sync.start()).thenAnswer((_) async {});
    when(() => sync.stop()).thenAnswer((_) async {});
    when(() => sync.sync()).thenAnswer((_) async {});

    final listBookmarks = MockListBookmarks();
    when(() => listBookmarks()).thenAnswer((_) async => const Ok([]));

    authCubit = AuthCubit(
      signIn: signIn,
      signOut: signOut,
      restoreSession: restoreSession,
    );
    themeCubit = ThemeCubit(await SharedPreferences.getInstance());
    bookmarksCubit = BookmarksListCubit(
      listBookmarks,
      MockDeleteBookmark(),
      sync,
    );
    homeCubit = HomeCubit(authCubit, bookmarksCubit);

    getIt.registerSingleton<HomeCubit>(homeCubit);
  });

  tearDown(() async {
    await getIt.reset();
    await homeCubit.close();
    await bookmarksCubit.close();
    await themeCubit.close();
    await authCubit.close();
    await syncStatusController.close();
  });

  testWidgets('signs in and lands on home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      App(authCubit: authCubit, themeCubit: themeCubit, bookmarksSync: sync),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('Sign in'), findsWidgets);

    await tester.enterText(find.byType(TextFormField).at(0), 'alice');
    await tester.enterText(find.byType(TextFormField).at(1), 'hunter2');

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(homeCubit.state.username, 'alice');
  });
}

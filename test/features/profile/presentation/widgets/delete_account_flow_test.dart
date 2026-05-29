import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_template/core/theme/theme_bloc.dart';
import 'package:flutter_starter_template/core/theme/theme_state.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/delete_account_cubit.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/delete_account_state.dart';
import 'package:flutter_starter_template/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_starter_template/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_starter_template/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:flutter_starter_template/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_utils.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockThemeBloc extends Mock implements ThemeBloc {}

class MockProfileBloc extends Mock implements ProfileBloc {}

class MockDeleteAccountCubit extends Mock implements DeleteAccountCubit {}

void main() {
  late MockAuthBloc authBloc;
  late MockThemeBloc themeBloc;
  late MockProfileBloc profileBloc;
  late MockDeleteAccountCubit deleteAccountCubit;

  setUp(() {
    authBloc = MockAuthBloc();
    themeBloc = MockThemeBloc();
    profileBloc = MockProfileBloc();
    deleteAccountCubit = MockDeleteAccountCubit();

    const authState = AuthState.authenticated(testUser);
    when(() => authBloc.state).thenReturn(authState);
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

    const themeState = ThemeState(
      mode: ThemeMode.system,
      scheme: ThemeState.defaultScheme,
    );
    when(() => themeBloc.state).thenReturn(themeState);
    when(() => themeBloc.stream).thenAnswer((_) => const Stream.empty());

    const profileState = ProfileState();
    when(() => profileBloc.state).thenReturn(profileState);
    when(() => profileBloc.stream).thenAnswer((_) => const Stream.empty());

    when(
      () => deleteAccountCubit.state,
    ).thenReturn(const DeleteAccountState.initial());
    when(
      () => deleteAccountCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => deleteAccountCubit.submit()).thenAnswer((_) async {});
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<ThemeBloc>.value(value: themeBloc),
            BlocProvider<ProfileBloc>.value(value: profileBloc),
            BlocProvider<DeleteAccountCubit>.value(value: deleteAccountCubit),
          ],
          child: const ProfileBody(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Delete stays disabled until the username is typed', (
    tester,
  ) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    // Dialog is shown with a disabled Delete button.
    expect(find.text('Delete account?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    verifyNever(() => deleteAccountCubit.submit());

    // Wrong text keeps it disabled.
    await tester.enterText(find.byType(TextField), 'bob');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    verifyNever(() => deleteAccountCubit.submit());
  });

  testWidgets('typing the username enables Delete and invokes submit', (
    tester,
  ) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), testUser.username);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    verify(() => deleteAccountCubit.submit()).called(1);
  });
}

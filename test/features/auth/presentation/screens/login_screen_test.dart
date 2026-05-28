import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_starter_template/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_starter_template/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_starter_template/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_utils.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

Widget wrapWithDependencies(AuthCubit cubit) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<AuthCubit>.value(
      value: cubit,
      child: const LoginScreen(),
    ),
  );
}

void main() {
  late MockAuthCubit mockCubit;

  setUp(() {
    mockCubit = MockAuthCubit();
    when(() => mockCubit.state).thenReturn(const AuthState.initial());
    when(
      () => mockCubit.stream,
    ).thenAnswer((_) => Stream.value(const AuthState.initial()));
  });

  group('LoginScreen', () {
    testWidgets('renders login form fields', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockCubit));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign in'), findsAtLeast(2));
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(wrapWithDependencies(mockCubit));
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Required'), findsAtLeast(1));
    });

    testWidgets('calls signIn with entered credentials', (tester) async {
      when(
        () => mockCubit.signIn(username: 'alice', password: 'hunter2'),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(wrapWithDependencies(mockCubit));
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(find.byType(TextFormField).at(0), 'alice');
      await tester.enterText(find.byType(TextFormField).at(1), 'hunter2');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        () => mockCubit.signIn(username: 'alice', password: 'hunter2'),
      ).called(1);
    });

    testWidgets('shows CircularProgressIndicator while submitting', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(const AuthState.submitting());
      when(
        () => mockCubit.stream,
      ).thenAnswer((_) => Stream.value(const AuthState.submitting()));

      await tester.pumpWidget(wrapWithDependencies(mockCubit));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message on auth failure', (tester) async {
      when(
        () => mockCubit.state,
      ).thenReturn(const AuthState.failure(testFailure));
      when(
        () => mockCubit.stream,
      ).thenAnswer((_) => Stream.value(const AuthState.failure(testFailure)));

      await tester.pumpWidget(wrapWithDependencies(mockCubit));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Something went wrong.'), findsOneWidget);
    });
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_utils.dart';

void main() {
  late MockSignIn mockSignIn;
  late MockSignOut mockSignOut;
  late MockRestoreSession mockRestoreSession;
  late MockAnalyticsService mockAnalytics;
  late AuthBloc bloc;

  setUp(() {
    mockSignIn = MockSignIn();
    mockSignOut = MockSignOut();
    mockRestoreSession = MockRestoreSession();
    mockAnalytics = MockAnalyticsService();
    stubAnalyticsService(mockAnalytics);
    bloc = AuthBloc(
      signIn: mockSignIn,
      signOut: mockSignOut,
      restoreSession: mockRestoreSession,
      analytics: mockAnalytics,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(bloc.state, const AuthState.initial());
    });

    group('restoreSession', () {
      blocTest<AuthBloc, AuthState>(
        'emits authenticated when session is restored',
        build: () {
          when(
            () => mockRestoreSession(),
          ).thenAnswer((_) async => const Ok(testUser));
          return bloc;
        },
        act: (bloc) => bloc.restoreSession(),
        expect: () => [const AuthState.authenticated(testUser)],
        verify: (_) {
          verify(() => mockAnalytics.setCurrentUser(testUser.id)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits initial when restore fails',
        build: () {
          when(
            () => mockRestoreSession(),
          ).thenAnswer((_) async => const Err(testFailure));
          return bloc;
        },
        act: (bloc) => bloc.restoreSession(),
        expect: () => [const AuthState.initial()],
        verify: (_) {
          verify(() => mockAnalytics.setCurrentUser(null)).called(1);
        },
      );
    });

    group('signIn', () {
      blocTest<AuthBloc, AuthState>(
        'emits submitting then authenticated on success',
        build: () {
          when(
            () => mockSignIn((username: 'alice', password: 'pass')),
          ).thenAnswer((_) async => const Ok(testUser));
          return bloc;
        },
        act: (bloc) => bloc.signIn(username: 'alice', password: 'pass'),
        expect: () => [
          const AuthState.submitting(),
          const AuthState.authenticated(testUser),
        ],
        verify: (_) {
          verify(() => mockAnalytics.setCurrentUser(testUser.id)).called(1);
          verify(() => mockAnalytics.logLogin(method: 'password')).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits submitting then failure on error',
        build: () {
          when(
            () => mockSignIn((username: 'bob', password: 'bad')),
          ).thenAnswer((_) async => const Err(testFailure));
          return bloc;
        },
        act: (bloc) => bloc.signIn(username: 'bob', password: 'bad'),
        expect: () => [
          const AuthState.submitting(),
          const AuthState.failure(testFailure),
        ],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'login_failed',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'does nothing when already submitting',
        build: () {
          when(
            () => mockSignIn((username: 'alice', password: 'pass')),
          ).thenAnswer((_) async => const Ok(testUser));
          return bloc;
        },
        seed: () => const AuthState.submitting(),
        act: (bloc) => bloc.signIn(username: 'alice', password: 'pass'),
        expect: () => <AuthState>[],
      );
    });

    group('signOut', () {
      blocTest<AuthBloc, AuthState>(
        'emits initial on successful sign out',
        build: () {
          when(() => mockSignOut()).thenAnswer((_) async => const Ok(null));
          return bloc;
        },
        seed: () => const AuthState.authenticated(testUser),
        act: (bloc) => bloc.signOut(),
        expect: () => [const AuthState.initial()],
        verify: (_) {
          verify(() => mockAnalytics.logEvent('sign_out')).called(1);
          verify(() => mockAnalytics.setCurrentUser(null)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'does nothing when sign out returns Err',
        build: () {
          when(
            () => mockSignOut(),
          ).thenAnswer((_) async => const Err(testFailure));
          return bloc;
        },
        seed: () => const AuthState.authenticated(testUser),
        act: (bloc) => bloc.signOut(),
        expect: () => <AuthState>[],
      );
    });
  });
}

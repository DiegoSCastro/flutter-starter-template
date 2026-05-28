import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_starter_template/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_utils.dart';

void main() {
  late MockSignIn mockSignIn;
  late MockSignOut mockSignOut;
  late MockRestoreSession mockRestoreSession;
  late AuthCubit cubit;

  setUp(() {
    mockSignIn = MockSignIn();
    mockSignOut = MockSignOut();
    mockRestoreSession = MockRestoreSession();
    cubit = AuthCubit(
      signIn: mockSignIn,
      signOut: mockSignOut,
      restoreSession: mockRestoreSession,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      expect(cubit.state, const AuthState.initial());
    });

    group('restoreSession', () {
      blocTest<AuthCubit, AuthState>(
        'emits authenticated when session is restored',
        build: () {
          when(
            () => mockRestoreSession(),
          ).thenAnswer((_) async => const Ok(testUser));
          return cubit;
        },
        act: (cubit) => cubit.restoreSession(),
        expect: () => [const AuthState.authenticated(testUser)],
      );

      blocTest<AuthCubit, AuthState>(
        'emits initial when restore fails',
        build: () {
          when(
            () => mockRestoreSession(),
          ).thenAnswer((_) async => const Err(testFailure));
          return cubit;
        },
        act: (cubit) => cubit.restoreSession(),
        expect: () => [const AuthState.initial()],
      );
    });

    group('signIn', () {
      blocTest<AuthCubit, AuthState>(
        'emits submitting then authenticated on success',
        build: () {
          when(
            () => mockSignIn(username: 'alice', password: 'pass'),
          ).thenAnswer((_) async => const Ok(testUser));
          return cubit;
        },
        act: (cubit) => cubit.signIn(username: 'alice', password: 'pass'),
        expect: () => [
          const AuthState.submitting(),
          const AuthState.authenticated(testUser),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits submitting then failure on error',
        build: () {
          when(
            () => mockSignIn(username: 'bob', password: 'bad'),
          ).thenAnswer((_) async => const Err(testFailure));
          return cubit;
        },
        act: (cubit) => cubit.signIn(username: 'bob', password: 'bad'),
        expect: () => [
          const AuthState.submitting(),
          const AuthState.failure(testFailure),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'does nothing when already submitting',
        build: () {
          when(
            () => mockSignIn(username: 'alice', password: 'pass'),
          ).thenAnswer((_) async => const Ok(testUser));
          return cubit;
        },
        seed: () => const AuthState.submitting(),
        act: (cubit) => cubit.signIn(username: 'alice', password: 'pass'),
        expect: () => <AuthState>[],
      );
    });

    group('signOut', () {
      blocTest<AuthCubit, AuthState>(
        'emits initial on successful sign out',
        build: () {
          when(() => mockSignOut()).thenAnswer((_) async => const Ok(null));
          return cubit;
        },
        seed: () => const AuthState.authenticated(testUser),
        act: (cubit) => cubit.signOut(),
        expect: () => [const AuthState.initial()],
      );

      blocTest<AuthCubit, AuthState>(
        'does nothing when sign out returns Err',
        build: () {
          when(
            () => mockSignOut(),
          ).thenAnswer((_) async => const Err(testFailure));
          return cubit;
        },
        seed: () => const AuthState.authenticated(testUser),
        act: (cubit) => cubit.signOut(),
        expect: () => <AuthState>[],
      );
    });
  });
}

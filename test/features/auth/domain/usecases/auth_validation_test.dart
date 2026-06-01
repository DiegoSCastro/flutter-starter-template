import 'package:flutter_starter_template/core/error/failure.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/change_password.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/register.dart';
import 'package:flutter_starter_template/features/auth/domain/usecases/sign_in.dart';
import 'package:flutter_starter_template/shared/domain/entities/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_utils.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  group('SignIn', () {
    test('rejects empty username without hitting repository', () async {
      final result = await SignIn(repo)((username: '', password: 'pw'));

      expect(result, isA<Err<AuthUser>>());
      expect(
        (result as Err<AuthUser>).failure,
        isA<InvalidCredentialsFailure>(),
      );
      verifyZeroInteractions(repo);
    });

    test('rejects empty password without hitting repository', () async {
      final result = await SignIn(repo)((username: 'alice', password: ''));

      expect(result, isA<Err<AuthUser>>());
      verifyZeroInteractions(repo);
    });

    test('delegates to repository when both fields present', () async {
      when(
        () => repo.signIn(username: 'alice', password: 'pw'),
      ).thenAnswer((_) async => const Ok(testUser));

      final result = await SignIn(repo)((username: 'alice', password: 'pw'));

      expect(result, isA<Ok<AuthUser>>());
      verify(() => repo.signIn(username: 'alice', password: 'pw')).called(1);
    });
  });

  group('Register', () {
    test('rejects empty credentials without hitting repository', () async {
      final result = await Register(repo)((username: '', password: ''));

      expect(result, isA<Err<AuthUser>>());
      expect(
        (result as Err<AuthUser>).failure,
        isA<InvalidCredentialsFailure>(),
      );
      verifyZeroInteractions(repo);
    });
  });

  group('ChangePassword', () {
    test('rejects empty currentPassword', () async {
      final result = await ChangePassword(repo)(
        (currentPassword: '', newPassword: 'new'),
      );

      expect(result, isA<Err<void>>());
      expect(
        (result as Err<void>).failure,
        isA<InvalidCredentialsFailure>(),
      );
      verifyZeroInteractions(repo);
    });

    test('rejects empty newPassword', () async {
      final result = await ChangePassword(repo)(
        (currentPassword: 'cur', newPassword: ''),
      );

      expect(result, isA<Err<void>>());
      verifyZeroInteractions(repo);
    });
  });
}

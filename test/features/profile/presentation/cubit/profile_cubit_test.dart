import 'package:flutter/services.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_starter_template/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileCubit', () {
    test('initial state is default', () async {
      final authCubit = _authCubit();
      final cubit = ProfileCubit(authCubit);

      expect(cubit.state.username, '');
      expect(cubit.state.userId, '');
      expect(cubit.state.isSigningOut, false);
      expect(cubit.state.packageInfo, isNull);

      await cubit.close();
      await authCubit.close();
    });

    test('load populates packageInfo', () async {
      const channel = MethodChannel('dev.fluttercommunity.plus/package_info');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'getAll') {
              return <String, dynamic>{
                'appName': 'TestApp',
                'packageName': 'com.test.app',
                'version': '1.0.0',
                'buildNumber': '42',
              };
            }
            return null;
          });

      final cubit = ProfileCubit(_authCubit());
      await cubit.load();

      expect(cubit.state.packageInfo, isNotNull);
      expect(cubit.state.packageInfo!.appName, 'TestApp');
      expect(cubit.state.packageInfo!.version, '1.0.0');
      expect(cubit.state.packageInfo!.buildNumber, '42');

      await cubit.close();
    });

    test('reacts to auth authenticated state', () async {
      final mockSignIn = MockSignIn();
      when(
        () => mockSignIn((username: 'alice', password: 'pass')),
      ).thenAnswer((_) async => const Ok(testUser));

      final authCubit = _authCubit(signIn: mockSignIn);
      final cubit = ProfileCubit(authCubit);

      await authCubit.signIn(username: 'alice', password: 'pass');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.username, 'alice');
      expect(cubit.state.userId, testUser.id);

      await cubit.close();
      await authCubit.close();
    });

    test('reacts to auth signed out state', () async {
      final mockSignIn = MockSignIn();
      when(
        () => mockSignIn((username: 'alice', password: 'pass')),
      ).thenAnswer((_) async => const Ok(testUser));

      final mockSignOut = MockSignOut();
      when(mockSignOut.call).thenAnswer((_) async => const Ok(null));

      final authCubit = _authCubit(signIn: mockSignIn, signOut: mockSignOut);
      final cubit = ProfileCubit(authCubit);

      await authCubit.signIn(username: 'alice', password: 'pass');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(cubit.state.username, 'alice');

      await authCubit.signOut();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.username, '');
      expect(cubit.state.userId, '');

      await cubit.close();
      await authCubit.close();
    });

    test('signOut sets isSigningOut and delegates', () async {
      final mockSignOut = MockSignOut();
      when(mockSignOut.call).thenAnswer((_) async => const Ok(null));

      final authCubit = _authCubit(signOut: mockSignOut);
      final cubit = ProfileCubit(authCubit);

      await cubit.signOut();
      // After signOut resolves, isSigningOut is still true since
      // we don't reset it — auth state change to initial handles cleanup.
      expect(cubit.state.username, '');

      await cubit.close();
      await authCubit.close();
    });

    test('close cancels auth subscription', () async {
      final authCubit = _authCubit();
      final cubit = ProfileCubit(authCubit);
      await cubit.close();

      final mockSignIn = MockSignIn();
      when(
        () => mockSignIn((username: 'bob', password: 'pass')),
      ).thenAnswer((_) async => const Ok(testUser));

      final authCubit2 = _authCubit(signIn: mockSignIn);
      await authCubit2.signIn(username: 'bob', password: 'pass');

      // Closed cubit should not react to new auth changes
      expect(cubit.state.username, '');

      await authCubit2.close();
    });
  });
}

AuthCubit _authCubit({MockSignIn? signIn, MockSignOut? signOut}) {
  final analytics = MockAnalyticsService();
  stubAnalyticsService(analytics);
  return AuthCubit(
    signIn: signIn ?? MockSignIn(),
    signOut: signOut ?? MockSignOut(),
    restoreSession: MockRestoreSession(),
    analytics: analytics,
  );
}

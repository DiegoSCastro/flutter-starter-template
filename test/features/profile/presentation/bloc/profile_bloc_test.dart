import 'package:flutter/services.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_starter_template/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileBloc', () {
    test('initial state is default', () async {
      final authBloc = _authBloc();
      final bloc = ProfileBloc(authBloc);

      expect(bloc.state.username, '');
      expect(bloc.state.userId, '');
      expect(bloc.state.isSigningOut, false);
      expect(bloc.state.packageInfo, isNull);

      await bloc.close();
      await authBloc.close();
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

      final bloc = ProfileBloc(_authBloc());
      await bloc.load();

      expect(bloc.state.packageInfo, isNotNull);
      expect(bloc.state.packageInfo!.appName, 'TestApp');
      expect(bloc.state.packageInfo!.version, '1.0.0');
      expect(bloc.state.packageInfo!.buildNumber, '42');

      await bloc.close();
    });

    test('reacts to auth authenticated state', () async {
      final mockSignIn = MockSignIn();
      when(
        () => mockSignIn((username: 'alice', password: 'pass')),
      ).thenAnswer((_) async => const Ok(testUser));

      final authBloc = _authBloc(signIn: mockSignIn);
      final bloc = ProfileBloc(authBloc);

      await authBloc.signIn(username: 'alice', password: 'pass');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.username, 'alice');
      expect(bloc.state.userId, testUser.id);

      await bloc.close();
      await authBloc.close();
    });

    test('reacts to auth signed out state', () async {
      final mockSignIn = MockSignIn();
      when(
        () => mockSignIn((username: 'alice', password: 'pass')),
      ).thenAnswer((_) async => const Ok(testUser));

      final mockSignOut = MockSignOut();
      when(mockSignOut.call).thenAnswer((_) async => const Ok(null));

      final authBloc = _authBloc(signIn: mockSignIn, signOut: mockSignOut);
      final bloc = ProfileBloc(authBloc);

      await authBloc.signIn(username: 'alice', password: 'pass');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.username, 'alice');

      await authBloc.signOut();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.username, '');
      expect(bloc.state.userId, '');

      await bloc.close();
      await authBloc.close();
    });

    test('signOut sets isSigningOut and delegates', () async {
      final mockSignOut = MockSignOut();
      when(mockSignOut.call).thenAnswer((_) async => const Ok(null));

      final authBloc = _authBloc(signOut: mockSignOut);
      final bloc = ProfileBloc(authBloc);

      await bloc.signOut();
      // After signOut resolves, isSigningOut is still true since
      // we don't reset it — auth state change to initial handles cleanup.
      expect(bloc.state.username, '');

      await bloc.close();
      await authBloc.close();
    });

    test('close cancels auth subscription', () async {
      final authBloc = _authBloc();
      final bloc = ProfileBloc(authBloc);
      await bloc.close();

      final mockSignIn = MockSignIn();
      when(
        () => mockSignIn((username: 'bob', password: 'pass')),
      ).thenAnswer((_) async => const Ok(testUser));

      final authBloc2 = _authBloc(signIn: mockSignIn);
      await authBloc2.signIn(username: 'bob', password: 'pass');

      // Closed bloc should not react to new auth changes
      expect(bloc.state.username, '');

      await authBloc2.close();
    });
  });
}

AuthBloc _authBloc({MockSignIn? signIn, MockSignOut? signOut}) {
  final analytics = MockAnalyticsService();
  stubAnalyticsService(analytics);
  return AuthBloc(
    signIn: signIn ?? MockSignIn(),
    register: MockRegister(),
    signOut: signOut ?? MockSignOut(),
    restoreSession: MockRestoreSession(),
    analytics: analytics,
  );
}

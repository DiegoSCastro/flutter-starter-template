import 'package:flutter/services.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileBloc', () {
    test('initial state is default', () async {
      final bloc = _profileBloc();

      expect(bloc.state.username, '');
      expect(bloc.state.userId, '');
      expect(bloc.state.isSigningOut, false);
      expect(bloc.state.signOutSucceeded, false);
      expect(bloc.state.packageInfo, isNull);

      await bloc.close();
    });

    test('load populates user and packageInfo', () async {
      _stubPackageInfo();
      final bloc = _profileBloc();

      bloc.add(const ProfileLoaded(testUser));
      await bloc.stream.firstWhere((state) => state.packageInfo != null);

      expect(bloc.state.username, 'alice');
      expect(bloc.state.userId, testUser.id);
      expect(bloc.state.packageInfo, isNotNull);
      expect(bloc.state.packageInfo!.appName, 'TestApp');
      expect(bloc.state.packageInfo!.version, '1.0.0');
      expect(bloc.state.packageInfo!.buildNumber, '42');

      await bloc.close();
    });

    test('signOut clears user and reports success', () async {
      final signOut = MockSignOut();
      when(signOut.call).thenAnswer((_) async => const Ok(null));
      final analytics = MockAnalyticsService();
      stubAnalyticsService(analytics);
      final bloc = _profileBloc(signOut: signOut, analytics: analytics);

      bloc.add(const ProfileSignOutRequested());
      await bloc.stream.firstWhere((state) => state.signOutSucceeded);

      expect(bloc.state.username, '');
      expect(bloc.state.userId, '');
      expect(bloc.state.isSigningOut, false);
      expect(bloc.state.signOutSucceeded, true);
      verify(signOut.call).called(1);
      verify(() => analytics.logEvent('sign_out')).called(1);
      verify(() => analytics.setCurrentUser(null)).called(1);

      await bloc.close();
    });

    test('signOut clears user when use case returns Err', () async {
      final signOut = MockSignOut();
      when(signOut.call).thenAnswer((_) async => const Err(testFailure));
      final bloc = _profileBloc(signOut: signOut);

      bloc.add(const ProfileSignOutRequested());
      await bloc.stream.firstWhere((state) => state.signOutSucceeded);

      expect(bloc.state.failure, testFailure);
      expect(bloc.state.isSigningOut, false);
      expect(bloc.state.signOutSucceeded, true);

      await bloc.close();
    });
  });
}

ProfileBloc _profileBloc({
  MockSignOut? signOut,
  MockAnalyticsService? analytics,
}) {
  final resolvedSignOut = signOut ?? MockSignOut();
  if (signOut == null) {
    when(resolvedSignOut.call).thenAnswer((_) async => const Ok(null));
  }
  final resolvedAnalytics = analytics ?? MockAnalyticsService();
  stubAnalyticsService(resolvedAnalytics);
  return ProfileBloc(resolvedSignOut, resolvedAnalytics);
}

void _stubPackageInfo() {
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
}

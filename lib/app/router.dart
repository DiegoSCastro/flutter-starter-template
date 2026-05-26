import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';

part 'router.g.dart';

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LoginScreen();
}

/// Builds the app router and wires auth redirects to [cubit] state changes.
GoRouter buildRouter(AuthCubit cubit) {
  return GoRouter(
    initialLocation: const HomeRoute().location,
    routes: $appRoutes,
    refreshListenable: _CubitListenable(cubit.stream),
    redirect: (context, state) {
      final isAuthenticated = cubit.state is AuthAuthenticated;
      final loggingIn = state.matchedLocation == const LoginRoute().location;
      if (!isAuthenticated && !loggingIn) return const LoginRoute().location;
      if (isAuthenticated && loggingIn) return const HomeRoute().location;
      return null;
    },
  );
}

/// Adapts a [Stream] to the [Listenable] contract GoRouter needs for
/// `refreshListenable`.
class _CubitListenable extends ChangeNotifier {
  _CubitListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

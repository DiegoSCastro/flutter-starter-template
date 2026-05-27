import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/bookmarks/presentation/screens/bookmark_detail_screen.dart';
import '../features/bookmarks/presentation/screens/bookmark_form_screen.dart';
import '../features/bookmarks/presentation/screens/bookmarks_list_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

part 'router.g.dart';

@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SplashScreen();
}

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LoginScreen();
}

@TypedGoRoute<BookmarksListRoute>(
  path: '/bookmarks',
  routes: [
    TypedGoRoute<BookmarkNewRoute>(path: 'new'),
    TypedGoRoute<BookmarkDetailRoute>(path: ':id'),
    TypedGoRoute<BookmarkEditRoute>(path: ':id/edit'),
  ],
)
class BookmarksListRoute extends GoRouteData with $BookmarksListRoute {
  const BookmarksListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BookmarksListScreen();
}

class BookmarkNewRoute extends GoRouteData with $BookmarkNewRoute {
  const BookmarkNewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BookmarkFormScreen();
}

class BookmarkDetailRoute extends GoRouteData with $BookmarkDetailRoute {
  const BookmarkDetailRoute(this.id);

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BookmarkDetailScreen(id: id);
}

class BookmarkEditRoute extends GoRouteData with $BookmarkEditRoute {
  const BookmarkEditRoute(this.id);

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BookmarkFormScreen(id: id);
}

/// Tracks deep-link targets and splash-screen completion so the redirect can
/// capture cold-start URIs and replay them after auth resolves.
class DeepLinkState {
  String? pendingRedirect;
  bool splashCompleted = false;
}

/// Singleton accessor set by [buildRouterWithDeepLink] so the splash screen
/// can reach the instance without constructor plumbing.
DeepLinkState? _deepLinkStateInstance;

/// Public getter for the splash screen to read [DeepLinkState.splashCompleted].
DeepLinkState get deepLinkState => _deepLinkStateInstance!;

/// Builds the app router and wires auth redirects to [cubit] state changes.
///
/// Returns both the router and the deep-link state so callers can hold a
/// reference, while the splash screen accesses it via [deepLinkState].
({GoRouter router, DeepLinkState deepLink}) buildRouterWithDeepLink(
  AuthCubit cubit,
) {
  final deepLink = DeepLinkState();
  _deepLinkStateInstance = deepLink;

  final router = GoRouter(
    // No initialLocation — GoRouter resolves the platform deep-link URI on
    // cold start and the redirect below captures it before sending the user
    // through splash / auth.
    routes: $appRoutes,
    refreshListenable: _CubitListenable(cubit.stream),
    redirect: (context, state) {
      final location = state.matchedLocation;
      final auth = cubit.state;

      // ── Phase 1: Before splash completes ──
      // Intercept every navigation until restoreSession runs.  The splash
      // screen sets splashCompleted = true after restore finishes.
      if (auth is AuthInitial && !deepLink.splashCompleted) {
        // Already on splash — let it run.
        if (location == '/splash') return null;
        // Any other location (deep link or default '/') — capture and
        // send through splash first.
        deepLink.pendingRedirect = state.uri.toString();
        return '/splash';
      }

      // ── Phase 2: Unauthenticated ──
      // Splash completed with no session, or user signed out.
      if (auth is AuthInitial || auth is AuthFailure) {
        if (location == '/login') return null;
        deepLink.pendingRedirect ??= state.uri.toString();
        return '/login';
      }

      // ── Phase 3: Authenticated ──
      if (auth is AuthAuthenticated) {
        // Leaving splash or login — restore the captured deep link.
        if (location == '/splash' || location == '/login') {
          final target = deepLink.pendingRedirect;
          deepLink.pendingRedirect = null;
          return target ?? '/';
        }
        // Already on a valid, protected route — allow it.
        return null;
      }

      // AuthSubmitting — don't interfere.
      return null;
    },
  );

  return (router: router, deepLink: deepLink);
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

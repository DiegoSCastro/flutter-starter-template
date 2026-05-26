// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $homeRoute,
  $loginRoute,
  $bookmarksListRoute,
];

RouteBase get $homeRoute =>
    GoRouteData.$route(path: '/', factory: $HomeRoute._fromState);

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $loginRoute =>
    GoRouteData.$route(path: '/login', factory: $LoginRoute._fromState);

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  @override
  String get location => GoRouteData.$location('/login');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $bookmarksListRoute => GoRouteData.$route(
  path: '/bookmarks',
  factory: $BookmarksListRoute._fromState,
  routes: [
    GoRouteData.$route(path: 'new', factory: $BookmarkNewRoute._fromState),
    GoRouteData.$route(path: ':id', factory: $BookmarkDetailRoute._fromState),
    GoRouteData.$route(
      path: ':id/edit',
      factory: $BookmarkEditRoute._fromState,
    ),
  ],
);

mixin $BookmarksListRoute on GoRouteData {
  static BookmarksListRoute _fromState(GoRouterState state) =>
      const BookmarksListRoute();

  @override
  String get location => GoRouteData.$location('/bookmarks');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BookmarkNewRoute on GoRouteData {
  static BookmarkNewRoute _fromState(GoRouterState state) =>
      const BookmarkNewRoute();

  @override
  String get location => GoRouteData.$location('/bookmarks/new');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BookmarkDetailRoute on GoRouteData {
  static BookmarkDetailRoute _fromState(GoRouterState state) =>
      BookmarkDetailRoute(state.pathParameters['id']!);

  BookmarkDetailRoute get _self => this as BookmarkDetailRoute;

  @override
  String get location =>
      GoRouteData.$location('/bookmarks/${Uri.encodeComponent(_self.id)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BookmarkEditRoute on GoRouteData {
  static BookmarkEditRoute _fromState(GoRouterState state) =>
      BookmarkEditRoute(state.pathParameters['id']!);

  BookmarkEditRoute get _self => this as BookmarkEditRoute;

  @override
  String get location =>
      GoRouteData.$location('/bookmarks/${Uri.encodeComponent(_self.id)}/edit');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

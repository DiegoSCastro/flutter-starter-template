import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/build_context_extensions.dart';
import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../core/theme/theme_state.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/bookmarks/domain/services/bookmarks_sync_controller.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

class App extends StatefulWidget {
  const App({super.key, this.authCubit, this.themeCubit, this.bookmarksSync});

  final AuthCubit? authCubit;
  final ThemeCubit? themeCubit;
  final BookmarksSyncController? bookmarksSync;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthCubit _authCubit;
  late final ThemeCubit _themeCubit;
  late final GoRouter _router;
  late final DeepLinkState _deepLink;
  late final BookmarksSyncController _sync;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authCubit = widget.authCubit ?? getIt<AuthCubit>();
    _themeCubit = widget.themeCubit ?? getIt<ThemeCubit>();
    final result = buildRouterWithDeepLink(_authCubit);
    _router = result.router;
    _deepLink = result.deepLink;
    _sync = widget.bookmarksSync ?? getIt<BookmarksSyncController>();
    _authSub = _authCubit.stream.listen(_onAuthChanged);
    // Session restoration is driven by SplashScreen so it can gate routing
    // on completion instead of racing the redirect.
  }

  void _onAuthChanged(AuthState state) {
    if (state is AuthAuthenticated) {
      _sync.start();
    } else {
      _sync.stop();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _sync.stop();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DeepLinkScope(
      deepLink: _deepLink,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authCubit),
          BlocProvider.value(value: _themeCubit),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) => MaterialApp.router(
            onGenerateTitle: (context) => context.l10n.appTitle,
            theme: AppTheme.light(scheme: themeState.scheme),
            darkTheme: AppTheme.dark(scheme: themeState.scheme),
            themeMode: themeState.mode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}

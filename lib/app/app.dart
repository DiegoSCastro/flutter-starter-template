import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../core/theme/theme_state.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/bookmarks/data/sync/bookmarks_sync_service.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthCubit _authCubit;
  late final ThemeCubit _themeCubit;
  late final GoRouter _router;
  late final BookmarksSyncService _sync;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
    _themeCubit = getIt<ThemeCubit>();
    _router = buildRouter(_authCubit);
    _sync = getIt<BookmarksSyncService>();
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) => MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          theme: AppTheme.light(scheme: themeState.scheme),
          darkTheme: AppTheme.dark(scheme: themeState.scheme),
          themeMode: themeState.mode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _router,
        ),
      ),
    );
  }
}

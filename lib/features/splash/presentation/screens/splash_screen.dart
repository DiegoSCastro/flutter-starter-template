import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:splashscreen/splashscreen.dart' as pkg;

import '../../../../core/build_context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

/// Bootstrap screen shown while [AuthCubit.restoreSession] runs.
///
/// Owns the post-restore redirect: routes to `/` on success, `/login`
/// otherwise. Enforces a minimum display time so the splash never flashes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const Duration _minDisplay = Duration(seconds: 2);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final cubit = context.auth;
    await Future.wait<void>([
      cubit.restoreSession(),
      Future<void>.delayed(SplashScreen._minDisplay),
    ]);
    if (!mounted) return;
    final next = cubit.state is AuthAuthenticated ? '/' : '/login';
    context.go(next);
  }

  @override
  Widget build(BuildContext context) {
    return pkg.SplashScreen(
      seconds: 60,
      navigateAfterSeconds: const _SplashFallback(),
      backgroundColor: context.colorScheme.surface,
      loaderColor: context.colorScheme.primary,
      useLoader: true,
      title: Text(
        'Flutter Starter',
        style: context.textTheme.headlineSmall?.copyWith(
          color: context.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      loadingText: const Text(''),
      loadingTextPadding: EdgeInsets.zero,
      styleTextUnderTheLoader: TextStyle(color: context.colorScheme.onSurface),
    );
  }
}

/// Safety net — only reached if `seconds` elapses before [_bootstrap] navigates.
class _SplashFallback extends StatelessWidget {
  const _SplashFallback();

  @override
  Widget build(BuildContext context) => const Scaffold();
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/splash_widgets.dart';

/// Bootstrap screen shown while [AuthSessionRestoreRequested] runs.
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
    final bloc = context.read<AuthBloc>();
    final restoreComplete = bloc.stream.firstWhere(
      (state) =>
          state is AuthAuthenticated ||
          state is AuthInitial ||
          state is AuthFailure,
    );
    bloc.add(const AuthSessionRestoreRequested());
    await Future.wait<void>([
      restoreComplete.then((_) {}),
      Future<void>.delayed(SplashScreen._minDisplay),
    ]);
    if (!mounted) return;
    DeepLinkScope.of(context).splashCompleted = true;
    const HomeRoute().go(context);
  }

  @override
  Widget build(BuildContext context) {
    return const SplashContent();
  }
}

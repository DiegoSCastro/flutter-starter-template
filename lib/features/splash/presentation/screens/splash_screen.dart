import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/build_context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

part '../widgets/splash_widgets.dart';

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
    final cubit = context.read<AuthCubit>();
    await Future.wait<void>([
      cubit.restoreSession(),
      Future<void>.delayed(SplashScreen._minDisplay),
    ]);
    if (!mounted) return;
    deepLinkState.splashCompleted = true;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return const _SplashContent();
  }
}

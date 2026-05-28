import 'package:flutter/material.dart';

import '../../../../core/build_context_extensions.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.appTitle,
              style: context.textTheme.headlineSmall?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(color: context.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../build_context_extensions.dart';

/// Full-screen error placeholder with an icon, message, and optional retry.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryLabel,
    this.icon = Icons.error_outline,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final effectiveOnRetry = onRetry != null
        ? () {
            HapticFeedback.lightImpact();
            onRetry!();
          }
        : null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.colorScheme.error),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: context.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: effectiveOnRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? context.l10n.commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

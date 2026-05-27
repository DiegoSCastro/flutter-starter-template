import 'package:flutter/material.dart';

/// Centered circular progress indicator with consistent sizing.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.size = 32, this.label});

  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(strokeWidth: 3),
          ),
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(label!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

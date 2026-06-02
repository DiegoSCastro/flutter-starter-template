import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../app_ui.dart';

enum AppButtonVariant { primary, tonal, outlined, text }

enum AppButtonSize { small, medium, large }

/// A single themed button that supports four visual variants, three sizes,
/// optional leading icon, and an in-place loading spinner.
///
/// Disable the button by passing `onPressed: null` or `isLoading: true`.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final FaIconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading
        ? null
        : onPressed != null
        ? () {
            HapticFeedback.lightImpact();
            onPressed!();
          }
        : null;
    final child = isLoading
        ? SizedBox(
            width: _spinnerSize,
            height: _spinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _spinnerColor(context),
            ),
          )
        : Text(label);

    final button = switch (variant) {
      AppButtonVariant.primary =>
        icon == null || isLoading
            ? FilledButton(
                onPressed: effectiveOnPressed,
                style: _style(),
                child: child,
              )
            : FilledButton.icon(
                onPressed: effectiveOnPressed,
                style: _style(),
                icon: FaIcon(icon),
                label: Text(label),
              ),
      AppButtonVariant.tonal =>
        icon == null || isLoading
            ? FilledButton.tonal(
                onPressed: effectiveOnPressed,
                style: _style(),
                child: child,
              )
            : FilledButton.tonalIcon(
                onPressed: effectiveOnPressed,
                style: _style(),
                icon: FaIcon(icon),
                label: Text(label),
              ),
      AppButtonVariant.outlined =>
        icon == null || isLoading
            ? OutlinedButton(
                onPressed: effectiveOnPressed,
                style: _style(),
                child: child,
              )
            : OutlinedButton.icon(
                onPressed: effectiveOnPressed,
                style: _style(),
                icon: FaIcon(icon),
                label: Text(label),
              ),
      AppButtonVariant.text =>
        icon == null || isLoading
            ? TextButton(
                onPressed: effectiveOnPressed,
                style: _style(),
                child: child,
              )
            : TextButton.icon(
                onPressed: effectiveOnPressed,
                style: _style(),
                icon: FaIcon(icon),
                label: Text(label),
              ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  double get _spinnerSize => switch (size) {
    AppButtonSize.small => 14,
    AppButtonSize.medium => 18,
    AppButtonSize.large => 20,
  };

  ButtonStyle _style() {
    final padding = switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      AppButtonSize.medium => const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: 14,
      ),
      AppButtonSize.large => const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
        vertical: 18,
      ),
    };

    final radius = switch (size) {
      AppButtonSize.small => 10.0,
      AppButtonSize.medium => 14.0,
      AppButtonSize.large => 16.0,
    };

    return ButtonStyle(
      padding: WidgetStatePropertyAll(padding),
      minimumSize: WidgetStatePropertyAll(
        Size(0, switch (size) {
          AppButtonSize.small => 36,
          AppButtonSize.medium => 48,
          AppButtonSize.large => 56,
        }),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      elevation: WidgetStatePropertyAll(
        variant == AppButtonVariant.primary ? 2 : 0,
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Color _spinnerColor(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.primary => context.colorScheme.onPrimary,
      AppButtonVariant.tonal => context.colorScheme.onSecondaryContainer,
      AppButtonVariant.outlined ||
      AppButtonVariant.text => context.colorScheme.primary,
    };
  }
}

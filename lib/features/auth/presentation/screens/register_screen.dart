import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../ui/animation/widget_animations.dart';
import '../../../../ui/theme/app_spacing.dart';
import '../../../../ui/widgets/widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      return;
    }

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  String _localizeFailure(Failure failure) => switch (failure) {
    InvalidCredentialsFailure() => context.l10n.errorInvalidCredentials,
    _ => context.l10n.errorUnknown,
  };

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.registerAppBarTitle,
      padding: EdgeInsets.zero,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isSubmitting = state is AuthSubmitting;
                final errorMessage = state is AuthFailure
                    ? _localizeFailure(state.failure)
                    : null;
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.l10n.registerHeadline,
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineSmall,
                      ).animateSlideDown(),
                      const SizedBox(height: AppSpacing.xxl),
                      AppTextField(
                        controller: _usernameController,
                        label: context.l10n.registerUsernameLabel,
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newUsername],
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? context.l10n.fieldRequired
                            : null,
                      ).animateSlideLeft(delay: 100.ms),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        controller: _passwordController,
                        label: context.l10n.registerPasswordLabel,
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: (value) => (value == null || value.isEmpty)
                            ? context.l10n.fieldRequired
                            : null,
                      ).animateSlideLeft(delay: 200.ms),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: context.l10n.registerConfirmPasswordLabel,
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.fieldRequired;
                          }
                          if (value != _passwordController.text) {
                            return context.l10n.errorPasswordsDoNotMatch;
                          }
                          return null;
                        },
                      ).animateSlideLeft(delay: 300.ms),
                      if (errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          errorMessage,
                          style: TextStyle(color: context.colorScheme.error),
                          textAlign: TextAlign.center,
                        ).animateShake(),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      AppButton(
                        label: context.l10n.registerSubmit,
                        onPressed: _submit,
                        isLoading: isSubmitting,
                        expand: true,
                      ).animateSlideUp(delay: 400.ms),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

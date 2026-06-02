import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/failure.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../ui/animation/widget_animations.dart';
import '../../../../ui/theme/app_spacing.dart';
import '../../../../ui/widgets/widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthSignInRequested(
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
      title: context.l10n.loginAppBarTitle,
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
                        context.l10n.loginHeadline,
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineSmall,
                      ).animateSlideDown(),
                      const SizedBox(height: AppSpacing.xxl),
                      AppTextField(
                        controller: _usernameController,
                        label: context.l10n.loginUsernameLabel,
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? context.l10n.fieldRequired
                            : null,
                      ).animateSlideLeft(delay: 100.ms),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        controller: _passwordController,
                        label: context.l10n.loginPasswordLabel,
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _submit(),
                        validator: (value) => (value == null || value.isEmpty)
                            ? context.l10n.fieldRequired
                            : null,
                      ).animateSlideLeft(delay: 200.ms),
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
                        label: context.l10n.loginSubmit,
                        onPressed: _submit,
                        isLoading: isSubmitting,
                        expand: true,
                      ).animateSlideUp(delay: 300.ms),
                      const SizedBox(height: AppSpacing.lg),
                      TextButton(
                        onPressed: isSubmitting
                            ? null
                            : () => const RegisterRoute().go(context),
                        child: Text(context.l10n.loginNavigateToRegister),
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

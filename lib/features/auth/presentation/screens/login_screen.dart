import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_inline_error.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/google_logo_mark.dart';
import '../../data/auth_repository.dart';
import '../../data/google_auth_service.dart';
import '../providers/auth_session_controller.dart';
import '../providers/otp_purpose.dart';
import 'otp_verify_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || _isGoogleSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final challenge = await ref.read(authRepositoryProvider).login(
            identifier: _identifier.text.trim(),
            password: _password.text,
          );

      if (!mounted) return;
      context.push(
        '/otp-verify',
        extra: OtpVerifyArgs(
          purpose: OtpPurpose.login,
          otpToken: challenge.otpToken,
          contactHint: challenge.maskedEmail,
        ),
      );
    } catch (e) {
      setState(() => _errorText = mapErrorToMessage(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isSubmitting || _isGoogleSubmitting) return;

    setState(() {
      _isGoogleSubmitting = true;
      _errorText = null;
    });

    try {
      final idToken = await ref.read(googleAuthServiceProvider).signInAndGetIdToken();
      final user = await ref.read(authRepositoryProvider).googleSignIn(idToken: idToken);
      ref.read(authSessionControllerProvider.notifier).setAuthenticated(user);
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _errorText = mapErrorToMessage(e));
    } finally {
      if (mounted) setState(() => _isGoogleSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const SizedBox(height: AppSpacing.xl),
              const Center(child: AppLogo(size: 80)),
              const SizedBox(height: AppSpacing.lg),
              Text('Welcome Back', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sign in to continue your studies',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_errorText != null) ...[
                AppInlineError(message: _errorText!),
                const SizedBox(height: AppSpacing.md),
              ],
              AppTextField(
                label: 'Email or Username',
                controller: _identifier,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Password',
                controller: _password,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(label: 'Sign In', isLoading: _isSubmitting, onPressed: _submit),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text('or', style: theme.textTheme.bodySmall),
                  ),
                  Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: (_isGoogleSubmitting || _isSubmitting) ? null : _signInWithGoogle,
                icon: _isGoogleSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CupertinoActivityIndicator())
                    : const GoogleLogoMark(),
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text("Don't have an account? Create one"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

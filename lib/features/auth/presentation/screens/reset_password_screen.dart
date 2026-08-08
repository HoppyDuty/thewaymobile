import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/notifications/snackbar_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/auth_repository.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.resetToken});

  final String resetToken;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _password.dispose();
    _passwordConfirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await ref.read(authRepositoryProvider).forgotPasswordReset(
            resetToken: widget.resetToken,
            password: _password.text,
            passwordConfirmation: _passwordConfirmation.text,
          );

      if (!mounted) return;
      ref.read(snackbarServiceProvider).showSuccess('Password reset. Please sign in.');
      context.go('/login');
    } catch (e) {
      setState(() => _errorText = mapErrorToMessage(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text('Choose a new password for your account.', style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              if (_errorText != null) ...[
                Text(_errorText!, style: TextStyle(color: theme.colorScheme.error)),
                const SizedBox(height: AppSpacing.md),
              ],
              AppTextField(
                label: 'New Password',
                controller: _password,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Confirm New Password',
                controller: _passwordConfirmation,
                obscureText: true,
                validator: (v) => v != _password.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: 'Reset Password', isLoading: _isSubmitting, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

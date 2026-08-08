import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/notifications/snackbar_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/auth_repository.dart';
import '../providers/otp_purpose.dart';
import 'otp_verify_screen.dart';

/// Step 1 of the forgot-password flow. `/auth/forgot-password` always
/// reports success regardless of whether the email exists
/// (anti-enumeration), but only returns a real `otp_token` when it does —
/// so this screen only advances to the OTP step when there's an actual
/// token to verify against; otherwise it shows the same generic message
/// and stays put (there's nothing to poll/verify without a token).
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final challenge = await ref.read(authRepositoryProvider).forgotPassword(email: _email.text.trim());

      if (!mounted) return;

      if (challenge == null) {
        ref.read(snackbarServiceProvider).showSuccess(
              "If that email is registered, we've sent a reset code to it.",
            );
        return;
      }

      context.push(
        '/otp-verify',
        extra: OtpVerifyArgs(
          purpose: OtpPurpose.forgotPassword,
          otpToken: challenge.otpToken,
          contactHint: _email.text.trim(),
        ),
      );
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
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                "Enter your account's email and we'll send you a code to reset your password.",
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_errorText != null) ...[
                Text(_errorText!, style: TextStyle(color: theme.colorScheme.error)),
                const SizedBox(height: AppSpacing.md),
              ],
              AppTextField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: 'Send Code', isLoading: _isSubmitting, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

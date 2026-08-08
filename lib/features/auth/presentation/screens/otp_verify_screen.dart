import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/notifications/snackbar_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/auth_repository.dart';
import '../providers/auth_session_controller.dart';
import '../providers/otp_purpose.dart';
import '../widgets/otp_input.dart';

/// Everything the OTP screen needs to know, passed via `go_router`'s
/// `extra` param (see `uiuxrules.md` §4 — typed navigation, no raw Maps).
class OtpVerifyArgs {
  const OtpVerifyArgs({required this.purpose, required this.otpToken, this.contactHint});

  final OtpPurpose purpose;
  final String otpToken;
  final String? contactHint;
}

class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key, required this.args});

  final OtpVerifyArgs args;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  late String _otpToken = widget.args.otpToken;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorText;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldown = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown -= 1);
      }
    });
  }

  Future<void> _verify(String code) async {
    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    final repo = ref.read(authRepositoryProvider);

    try {
      switch (widget.args.purpose) {
        case OtpPurpose.registration:
          final user = await repo.verifyRegistration(otpToken: _otpToken, code: code);
          ref.read(authSessionControllerProvider.notifier).setAuthenticated(user);
          if (mounted) context.go('/home');
        case OtpPurpose.login:
          final user = await repo.verifyLogin(otpToken: _otpToken, code: code);
          ref.read(authSessionControllerProvider.notifier).setAuthenticated(user);
          if (mounted) context.go('/home');
        case OtpPurpose.forgotPassword:
          final resetToken = await repo.forgotPasswordVerify(otpToken: _otpToken, code: code);
          if (mounted) context.push('/reset-password', extra: resetToken);
      }
    } catch (e) {
      setState(() => _errorText = mapErrorToMessage(e));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      final challenge = await ref.read(authRepositoryProvider).resendOtp(
            otpToken: _otpToken,
            type: widget.args.purpose.apiValue,
          );
      _otpToken = challenge.otpToken;
      _startCooldown(challenge.resendAfter ?? 60);
      ref.read(snackbarServiceProvider).showSuccess('A new code has been sent.');
    } catch (e) {
      ref.read(snackbarServiceProvider).showError(mapErrorToMessage(e));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hint = widget.args.contactHint;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Code')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                hint != null ? 'Enter the 6-digit code sent to $hint' : 'Enter the 6-digit code we sent you',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              OtpInput(onCompleted: _verify),
              const SizedBox(height: AppSpacing.md),
              if (_errorText != null)
                Text(_errorText!, style: TextStyle(color: theme.colorScheme.error)),
              if (_isVerifying) ...[
                const SizedBox(height: AppSpacing.md),
                const Center(child: CircularProgressIndicator()),
              ],
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: _resendCooldown > 0
                    ? Text('Resend code in ${_resendCooldown}s', style: theme.textTheme.bodyMedium)
                    : AppButton(
                        label: 'Resend Code',
                        isLoading: _isResending,
                        onPressed: _resend,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

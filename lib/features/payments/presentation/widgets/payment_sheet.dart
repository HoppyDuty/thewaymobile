import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/env/env.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/payment_models.dart';
import '../../data/payment_api.dart';
import '../screens/payment_webview_screen.dart';

/// The one payment entry point every purchasable feature (CBT exam access,
/// video courses, books) should use — same gateway choice, same manual-bank
/// flow, same polling logic, regardless of what's being bought.
///
/// Returns `true` if the payment was confirmed successful before the sheet
/// closed (online gateways only — manual payments are admin-approved later,
/// so they always return `false` here even on a well-formed submission).
Future<bool> showPaymentSheet(
  BuildContext context,
  WidgetRef ref, {
  required String contentType,
  required int contentId,
  required String contentTitle,
  required num price,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _PaymentGatewaySheet(
      contentType: contentType,
      contentId: contentId,
      contentTitle: contentTitle,
      price: price,
    ),
  );
  return result ?? false;
}

class _PaymentGatewaySheet extends ConsumerStatefulWidget {
  const _PaymentGatewaySheet({
    required this.contentType,
    required this.contentId,
    required this.contentTitle,
    required this.price,
  });

  final String contentType;
  final int contentId;
  final String contentTitle;
  final num price;

  @override
  ConsumerState<_PaymentGatewaySheet> createState() => _PaymentGatewaySheetState();
}

class _PaymentGatewaySheetState extends ConsumerState<_PaymentGatewaySheet> {
  String _gateway = PaymentGateway.paystack;
  bool _isProcessing = false;
  PaymentInitiation? _manualInitiation;

  static const _gateways = [
    (value: PaymentGateway.paystack, label: 'Paystack', icon: Icons.credit_card),
    (value: PaymentGateway.flutterwave, label: 'Flutterwave', icon: Icons.account_balance_wallet_outlined),
    (value: PaymentGateway.manual, label: 'Bank Transfer (Manual)', icon: Icons.account_balance_outlined),
  ];

  Future<void> _pay() async {
    setState(() => _isProcessing = true);
    try {
      final initiation = await ref
          .read(paymentApiProvider)
          .initiate(contentType: widget.contentType, contentId: widget.contentId, gateway: _gateway);

      if (!mounted) return;

      if (_gateway == PaymentGateway.manual) {
        setState(() {
          _manualInitiation = initiation;
          _isProcessing = false;
        });
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentWebViewScreen(url: initiation.paymentUrl!, title: widget.contentTitle),
        ),
      );

      if (!mounted) return;
      final confirmed = await _pollForConfirmation(initiation.paymentUuid);
      if (!mounted) return;
      Navigator.of(context).pop(confirmed);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mapErrorToMessage(e))));
    }
  }

  Future<bool> _pollForConfirmation(String paymentUuid) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: AppSpacing.md),
            Expanded(child: Text('Confirming your payment…')),
          ],
        ),
      ),
    );

    var confirmed = false;
    for (var attempt = 0; attempt < 40; attempt++) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        final verification = await ref.read(paymentApiProvider).verify(paymentUuid);
        if (verification.isSuccessful) {
          confirmed = true;
          break;
        }
      } catch (_) {
        // transient network hiccup while polling — keep trying
      }
    }

    if (mounted) Navigator.of(context).pop();
    return confirmed;
  }

  Future<void> _copyAccountNumber(String accountNumber) async {
    await Clipboard.setData(ClipboardData(text: accountNumber));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account number copied.')));
  }

  Future<void> _messageAdminOnWhatsapp(PaymentInitiation initiation) async {
    final message =
        "Hi, I've made a bank transfer of ₦${initiation.amount.toStringAsFixed(0)} "
        'for "${widget.contentTitle}" (Ref: ${initiation.reference}). '
        'I will attach my proof of payment.';
    final uri = Uri.parse('https://wa.me/${Env.supportWhatsappNumber}?text=${Uri.encodeComponent(message)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.contentTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('₦${widget.price.toStringAsFixed(0)}', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            if (_manualInitiation != null)
              _ManualPaymentDetails(
                initiation: _manualInitiation!,
                onCopy: _copyAccountNumber,
                onMessageAdmin: () => _messageAdminOnWhatsapp(_manualInitiation!),
                onDone: () => Navigator.of(context).pop(false),
              )
            else ...[
              for (final gateway in _gateways)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: gateway.value,
                  groupValue: _gateway,
                  onChanged: (v) => setState(() => _gateway = v!),
                  title: Row(
                    children: [
                      Icon(gateway.icon, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(gateway.label),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Pay ₦${widget.price.toStringAsFixed(0)}',
                isLoading: _isProcessing,
                onPressed: _pay,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ManualPaymentDetails extends StatelessWidget {
  const _ManualPaymentDetails({
    required this.initiation,
    required this.onCopy,
    required this.onMessageAdmin,
    required this.onDone,
  });

  final PaymentInitiation initiation;
  final ValueChanged<String> onCopy;
  final VoidCallback onMessageAdmin;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = initiation.manualDetails;
    if (details == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: AppRadius.mdRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'Bank', value: details.bankName),
              _DetailRow(label: 'Account Name', value: details.accountName),
              _DetailRow(
                label: 'Account Number',
                value: details.accountNumber,
                trailing: IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy',
                  onPressed: () => onCopy(details.accountNumber),
                ),
              ),
              const Divider(),
              _DetailRow(label: 'Reference', value: initiation.reference),
              const SizedBox(height: AppSpacing.sm),
              Text(details.instructions, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Message Admin on WhatsApp',
          icon: Icons.chat_outlined,
          onPressed: onMessageAdmin,
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(onPressed: onDone, child: const Text('Done')),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: theme.textTheme.titleSmall)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

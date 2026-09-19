import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/profile_models.dart';
import '../providers/payment_history_controller.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      ref.read(paymentHistoryControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: state.when(
        loading: () => AppShimmer(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 6,
            itemBuilder: (context, index) => const ShimmerListTile(),
          ),
        ),
        error: (error, _) => AppErrorState(
          message: mapErrorToMessage(error),
          onRetry: () => ref.invalidate(paymentHistoryControllerProvider),
        ),
        data: (data) {
          if (data.items.isEmpty) {
            return const AppEmptyState(
              title: 'No payments yet',
              message: 'Your transaction history will appear here.',
              icon: AppIcons.receipt,
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(paymentHistoryControllerProvider.notifier).refresh(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: data.items.length + (data.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= data.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Center(child: CupertinoActivityIndicator()),
                  );
                }
                return _PaymentTile(payment: data.items[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

Color _statusColor(BuildContext context, String status) {
  final appColors = context.appColors;
  switch (status) {
    case 'successful':
      return appColors.success;
    case 'pending':
      return appColors.warning;
    case 'failed':
      return appColors.danger;
    default:
      return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});

  final PaymentHistoryItem payment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(context, payment.status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(AppIcons.receipt, color: color),
        ),
        title: Text(payment.contentTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${payment.gateway} · ${DateFormat.yMMMd().format(payment.createdAt)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(payment.formatted.isNotEmpty ? payment.formatted : '₦${payment.amount.toStringAsFixed(0)}'),
            Text(payment.status, style: theme.textTheme.bodySmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

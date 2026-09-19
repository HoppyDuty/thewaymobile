import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_unlock_card.dart';
import '../../../payments/data/models/payment_models.dart';
import '../../../payments/presentation/widgets/payment_sheet.dart';
import '../../data/models/exam_type_model.dart';
import '../../data/services/cbt_sync_service.dart';
import '../providers/cbt_flow_args.dart';

/// Choose one of the 5 exam modes for [examType] — each carries a distinct
/// subject-count/timer/year/topic contract enforced downstream by
/// `OfflineQuestionBuilder`/`StartSessionRequest`. Shown up front so the
/// user knows what they're picking rather than discovering the rules
/// mid-setup. Free users can still practice (5 questions/subject, per
/// `QuestionBuilderService`) — the "Unlock Full Access" banner is an
/// upsell, not a gate.
class ModeSelectionScreen extends ConsumerStatefulWidget {
  const ModeSelectionScreen({super.key, required this.examType});

  final ExamTypeModel examType;

  @override
  ConsumerState<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends ConsumerState<ModeSelectionScreen> {
  late bool _isPaid = ref.read(cbtSyncServiceProvider).getPaidAccess(widget.examType.id);

  Future<void> _unlock() async {
    final confirmed = await showPaymentSheet(
      context,
      ref,
      contentType: PaymentContentType.examType,
      contentId: widget.examType.id,
      contentTitle: widget.examType.name,
      price: widget.examType.price,
    );
    if (confirmed) {
      await ref.read(cbtSyncServiceProvider).cachePaidAccess(widget.examType.id, true);
      if (mounted) setState(() => _isPaid = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final examType = widget.examType;

    return Scaffold(
      appBar: AppBar(title: Text(examType.name)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (examType.price > 0 && !_isPaid) ...[
            AppUnlockCard(
              title: 'Unlock Full Access — ₦${examType.price.toStringAsFixed(0)}',
              subtitle: 'Free practice is limited to 5 questions per subject.',
              onTap: _unlock,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          for (final info in ExamModeInfo.all)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.sm),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    child: Icon(info.icon),
                  ),
                  title: Text(info.title, style: theme.textTheme.titleMedium),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(info.description),
                  ),
                  trailing: const Icon(AppIcons.chevronRight),
                  onTap: () =>
                      context.push('/cbt/subjects', extra: CbtFlowArgs(examType: examType, mode: info.mode)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

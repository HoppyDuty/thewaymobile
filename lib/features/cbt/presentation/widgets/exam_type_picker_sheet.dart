import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/exam_type_model.dart';
import '../../data/models/offline_session_model.dart';
import '../providers/cbt_flow_args.dart';
import '../providers/exam_types_controller.dart';

/// Home's "Topical Study" quick action opens this — pick an exam type,
/// then go straight to subject → topic selection with the mode already
/// fixed to [ExamMode.topical] (skipping the mode-selection screen, since
/// the mode is already decided).
Future<void> showTopicalExamTypePicker(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _ExamTypePickerSheet(),
  );
}

class _ExamTypePickerSheet extends ConsumerWidget {
  const _ExamTypePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examTypesControllerProvider);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Topical Study', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose an exam type to study by topic.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: state.when(
                  loading: () => AppShimmer(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 4,
                      itemBuilder: (context, index) => const ListTile(
                        leading: CircleAvatar(),
                        title: SizedBox(height: 14),
                      ),
                    ),
                  ),
                  error: (error, _) => const AppEmptyState(
                    title: 'Could not load exam types',
                    message: 'Connect to the internet at least once to sync the question bank.',
                    icon: Icons.wifi_off_rounded,
                  ),
                  data: (examTypes) {
                    if (examTypes.isEmpty) {
                      return const AppEmptyState(
                        title: 'No exam types synced yet',
                        message: 'Connect to the internet at least once to sync the question bank.',
                        icon: Icons.quiz_outlined,
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: examTypes.length,
                      itemBuilder: (context, index) => _ExamTypeRow(examType: examTypes[index]),
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.viewPaddingOf(context).bottom + AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamTypeRow extends StatelessWidget {
  const _ExamTypeRow({required this.examType});

  final ExamTypeModel examType;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      leading: ClipRRect(
        borderRadius: AppRadius.smRadius,
        child: AppNetworkImage(url: examType.imageUrl, width: 44, height: 44),
      ),
      title: Text(examType.name),
      subtitle: Text('${examType.subjects.length} subjects'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).pop();
        context.push('/cbt/subjects', extra: CbtFlowArgs(examType: examType, mode: ExamMode.topical));
      },
    );
  }
}

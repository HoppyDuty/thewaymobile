import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/exam_type_model.dart';
import '../providers/exam_types_controller.dart';
import '../widgets/sync_badge.dart';

/// The CBT tab root — every synced exam type, tap through to mode
/// selection. Reads straight from Hive so it renders instantly offline.
class ExamTypesScreen extends ConsumerWidget {
  const ExamTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examTypesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CBT Practice'),
        actions: [
          const SyncBadge(),
          IconButton(
            icon: const Icon(AppIcons.bookmark),
            tooltip: 'My Questions',
            onPressed: () => context.push('/cbt/bookmarks'),
          ),
        ],
      ),
      body: state.when(
        loading: () => AppShimmer(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: AppSpacing.md, crossAxisSpacing: AppSpacing.md, childAspectRatio: 0.95),
            itemCount: 6,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.lgRadius),
            ),
          ),
        ),
        error: (error, _) => AppErrorState(
          message: mapErrorToMessage(error),
          onRetry: () => ref.invalidate(examTypesControllerProvider),
        ),
        data: (examTypes) {
          if (examTypes.isEmpty) {
            return AppEmptyState(
              title: 'No exam types synced yet',
              message: 'Connect to the internet once to download the question bank — after that it works offline.',
              icon: AppIcons.quiz,
              action: OutlinedButton.icon(
                onPressed: () => ref.read(examTypesControllerProvider.notifier).refresh(),
                icon: const Icon(AppIcons.refresh),
                label: const Text('Sync now'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(examTypesControllerProvider.notifier).refresh(),
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.95,
              ),
              itemCount: examTypes.length,
              itemBuilder: (context, index) => _ExamTypeCard(examType: examTypes[index]),
            ),
          );
        },
      ),
    );
  }
}

class _ExamTypeCard extends StatelessWidget {
  const _ExamTypeCard({required this.examType});

  final ExamTypeModel examType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      child: InkWell(
        onTap: () => context.push('/cbt/mode', extra: examType),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: AppNetworkImage(url: examType.imageUrl),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    examType.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${examType.subjects.length} subjects',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  if (examType.price > 0) ...[
                    const SizedBox(height: 4),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      label: Text('₦${examType.price.toStringAsFixed(0)}'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

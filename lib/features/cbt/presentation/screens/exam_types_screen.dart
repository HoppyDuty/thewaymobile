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
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 5,
            itemBuilder: (context, index) => Container(
              height: 88,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: examTypes.length,
              itemBuilder: (context, index) => _ExamTypeCard(examType: examTypes[index]),
            ),
          );
        },
      ),
    );
  }
}

/// A full-width, identity-first row: logo, name, short description — no
/// subject count, price, or other metadata that doesn't help the user
/// recognize *which* exam type this is (spec: CBT Practice cards communicate
/// identity/purpose, not stats).
class _ExamTypeCard extends StatelessWidget {
  const _ExamTypeCard({required this.examType});

  final ExamTypeModel examType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      child: InkWell(
        onTap: () => context.push('/cbt/mode', extra: examType),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              AppNetworkImage(url: examType.imageUrl, width: 56, height: 56, borderRadius: AppRadius.mdRadius),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      examType.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if ((examType.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        examType.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(AppIcons.chevronRight, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

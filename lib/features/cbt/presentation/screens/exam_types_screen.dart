import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/storage/hive_setup.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/exam_type_model.dart';
import '../../data/models/offline_session_model.dart';
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

          final resumable = _findResumableSession();

          return RefreshIndicator(
            onRefresh: () => ref.read(examTypesControllerProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: examTypes.length + (resumable != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (resumable != null) {
                  if (index == 0) return _ContinueExamCard(session: resumable);
                  return _ExamTypeCard(examType: examTypes[index - 1]);
                }
                return _ExamTypeCard(examType: examTypes[index]);
              },
            ),
          );
        },
      ),
    );
  }

  /// Most recently started session still `in_progress` — a killed app,
  /// backgrounded exam, or a deliberate "leave exam" all land here with no
  /// dedicated resume UI otherwise (autosave already persists everything
  /// needed to pick back up; nothing previously read it back).
  OfflineSessionModel? _findResumableSession() {
    OfflineSessionModel? latest;
    for (final session in HiveSetup.offlineSessionsBox.values) {
      if (session.status != SessionStatus.inProgress) continue;
      if (latest == null || session.startedAt > latest.startedAt) latest = session;
    }
    return latest;
  }
}

class _ContinueExamCard extends StatelessWidget {
  const _ContinueExamCard({required this.session});

  final OfflineSessionModel session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final examType = HiveSetup.examTypesBox.get(session.examTypeId);
    final answered = session.answers.values.where((v) => v.isNotEmpty).length;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      child: InkWell(
        onTap: () => context.push('/cbt/exam/${session.offlineUuid}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(AppIcons.quiz, color: theme.colorScheme.onPrimaryContainer),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue exam',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${examType?.name ?? 'Exam'} — $answered of ${session.questionIds.length} answered',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
              Icon(AppIcons.chevronRight, color: theme.colorScheme.onPrimaryContainer),
            ],
          ),
        ),
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

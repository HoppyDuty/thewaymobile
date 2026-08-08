import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/weak_area_models.dart';
import '../providers/weak_area_controller.dart';

class WeakAreasScreen extends ConsumerWidget {
  const WeakAreasScreen({super.key});

  Future<void> _analyze(BuildContext context, WidgetRef ref) async {
    await ref.read(weakAreaControllerProvider.notifier).analyze();
    final result = ref.read(weakAreaControllerProvider);
    if (result.hasError && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mapErrorToMessage(result.error!))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weakAreaControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Weak Area Analysis')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mapErrorToMessage(error), textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                AppButton(label: 'Try Again', onPressed: () => _analyze(context, ref)),
              ],
            ),
          ),
        ),
        data: (analysis) {
          if (analysis == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.insights_outlined, size: 64, color: theme.colorScheme.outline),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Get an AI-powered breakdown of which subjects need the most work, based on your CBT history.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(label: 'Analyze My Performance', onPressed: () => _analyze(context, ref)),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _analyze(context, ref),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(analysis.narrative, style: theme.textTheme.bodyMedium),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Subject Breakdown', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final subject in analysis.weakSubjects) _SubjectRow(subject: subject),
                const SizedBox(height: AppSpacing.lg),
                Text('Recommendations', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final rec in analysis.recommendations) _RecommendationCard(recommendation: rec),
                if (analysis.nextAllowedAt != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Next analysis available ${_formatDate(analysis.nextAllowedAt!)}.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.subject});

  final WeakSubject subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = subject.isWeak ? theme.colorScheme.error : context.appColors.success;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(subject.subjectName, style: theme.textTheme.titleSmall),
                Text('${subject.avgScore.toStringAsFixed(1)}%', style: TextStyle(color: color)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: AppRadius.smRadius,
              child: LinearProgressIndicator(
                value: (subject.avgScore / 100).clamp(0, 1),
                minHeight: 6,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text('${subject.attemptCount} exam(s) taken', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation});

  final StudyRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        leading: CircleAvatar(child: Text('${recommendation.priority}')),
        title: Text(recommendation.subject, style: theme.textTheme.titleSmall),
        subtitle: Text('${recommendation.action}\n${recommendation.resource}'),
        isThreeLine: true,
      ),
    );
  }
}

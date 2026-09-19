import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/study_plan_models.dart';
import '../providers/study_plan_controller.dart';

class StudyPlanScreen extends ConsumerWidget {
  const StudyPlanScreen({super.key});

  Future<void> _openGenerateSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _GeneratePlanSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyPlanControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Study Plan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openGenerateSheet(context, ref),
        icon: const Icon(AppIcons.sparkles),
        label: const Text('Generate Plan'),
      ),
      body: state.when(
        loading: () => const Center(child: CupertinoActivityIndicator(radius: 14)),
        error: (error, _) => AppErrorState(
          message: mapErrorToMessage(error),
          onRetry: () => ref.invalidate(studyPlanControllerProvider),
        ),
        data: (plan) {
          if (plan == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.calendar, size: 64, color: theme.colorScheme.outline),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Generate a personalised, week-by-week study plan tailored to your exam date.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(label: 'Generate Plan', onPressed: () => _openGenerateSheet(context, ref)),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.examType, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Exam date: ${plan.examDate} · ${plan.weeksRemaining} week(s) remaining'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final week in plan.weeklyPlan) _WeekCard(week: week),
            ],
          );
        },
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.week});

  final StudyPlanWeek week;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      child: ExpansionTile(
        title: Text('Week ${week.week}: ${week.theme}', style: theme.textTheme.titleSmall),
        subtitle: Text('${week.dailyTargetMinutes} min/day'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (week.topics.isNotEmpty) ...[
                  Text('Topics', style: theme.textTheme.labelLarge),
                  Wrap(spacing: AppSpacing.xs, children: [for (final t in week.topics) Chip(label: Text(t))]),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (week.goals.isNotEmpty) ...[
                  Text('Goals', style: theme.textTheme.labelLarge),
                  for (final g in week.goals)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(children: [const Text('• '), Expanded(child: Text(g))]),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (week.resources.isNotEmpty) ...[
                  Text('Resources', style: theme.textTheme.labelLarge),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [for (final r in week.resources) Chip(label: Text(r))],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratePlanSheet extends ConsumerStatefulWidget {
  const _GeneratePlanSheet();

  @override
  ConsumerState<_GeneratePlanSheet> createState() => _GeneratePlanSheetState();
}

class _GeneratePlanSheetState extends ConsumerState<_GeneratePlanSheet> {
  DateTime? _examDate;
  final _contextController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _examDate = picked);
  }

  Future<void> _generate() async {
    if (_examDate == null) return;

    setState(() => _isGenerating = true);
    try {
      await ref
          .read(studyPlanControllerProvider.notifier)
          .generate(
            examDate: _examDate!,
            extraContext: _contextController.text.trim().isEmpty ? null : _contextController.text.trim(),
          );
      final result = ref.read(studyPlanControllerProvider);
      if (mounted) {
        if (result.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mapErrorToMessage(result.error!))));
        } else {
          Navigator.of(context).pop();
        }
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Generate Study Plan', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(AppIcons.calendar),
            label: Text(
              _examDate == null
                  ? 'Choose your exam date'
                  : '${_examDate!.day}/${_examDate!.month}/${_examDate!.year}',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Anything else Shepherd should know? (optional)', controller: _contextController),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Generate Plan',
            isLoading: _isGenerating,
            onPressed: _examDate == null ? null : _generate,
          ),
        ],
      ),
    );
  }
}

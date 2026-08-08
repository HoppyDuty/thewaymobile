import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/review_prompt_service.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/exam_session_controller.dart';

/// Threshold above which a submitted result feels like a genuine win worth
/// celebrating — matches this app's informal "pass" bar for percentage-style
/// exam types (see `ScoringService`'s percentage-average path).
const _celebrationThresholdPercent = 70.0;

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.sessionKey});

  final String sessionKey;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  bool _celebrated = false;

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _maybeCelebrate(num percent) {
    if (_celebrated) return;
    _celebrated = true;

    if (percent >= _celebrationThresholdPercent) {
      _confettiController.play();
    }

    // Best-effort, fire-and-forget — never blocks or affects this screen.
    unawaited(ref.read(reviewPromptServiceProvider).maybePromptAfterExam());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(examSessionControllerProvider(widget.sessionKey)).valueOrNull;
    final result = state?.result;

    if (result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final percent = result.maxScore > 0 ? (result.score / result.maxScore * 100).clamp(0, 100) : 0.0;

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeCelebrate(percent));

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Result'), automaticallyImplyLeading: false),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 160,
                              height: 160,
                              child: CircularProgressIndicator(
                                value: percent / 100,
                                strokeWidth: 10,
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${percent.toStringAsFixed(1)}%', style: theme.textTheme.headlineMedium),
                                Text(
                                  '${result.score.toStringAsFixed(1)} / ${result.maxScore.toStringAsFixed(0)}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (result.isOfflinePreview)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: AppRadius.mdRadius,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cloud_off_rounded, size: 16, color: theme.colorScheme.onTertiaryContainer),
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: Text(
                                  result.pendingAiGradingCount > 0
                                      ? 'Preview score — theory answers and final score will update once this syncs online.'
                                      : 'Offline result — will sync automatically once you\'re back online.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(label: 'Correct', value: '${result.correct}', color: context.appColors.success),
                    ),
                    Expanded(
                      child: _StatTile(label: 'Wrong', value: '${result.wrong}', color: theme.colorScheme.error),
                    ),
                    Expanded(
                      child: _StatTile(
                        label: 'Skipped',
                        value: '${result.skipped}',
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Subject Breakdown', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final subject in result.subjectBreakdown)
                  Card(
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
                              Text('${subject.scorePercent.toStringAsFixed(1)}%'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          ClipRRect(
                            borderRadius: AppRadius.smRadius,
                            child: LinearProgressIndicator(
                              value: subject.maxScore > 0 ? (subject.score / subject.maxScore).clamp(0, 1) : 0,
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${subject.correct} correct · ${subject.wrong} wrong · ${subject.skipped} skipped',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Review Answers',
                  icon: Icons.fact_check_outlined,
                  onPressed: () => context.push('/cbt/exam/${widget.sessionKey}/review'),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => context.go('/cbt'),
                  child: const Text('Done'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 24,
                gravity: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(color: color)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/storage/hive_setup.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../shepherd/presentation/widgets/ask_shepherd_sheet.dart';
import '../../data/models/question_model.dart';
import '../providers/exam_session_controller.dart';
import '../widgets/calculator_sheet.dart';
import '../widgets/question_card.dart';

class ExamScreen extends ConsumerWidget {
  const ExamScreen({super.key, required this.sessionKey});

  final String sessionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examSessionControllerProvider(sessionKey));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmExit(context, ref);
      },
      child: Scaffold(
        body: SafeArea(
          child: state.when(
            loading: () => const Center(child: CupertinoActivityIndicator(radius: 14)),
            error: (error, _) => AppErrorState(message: mapErrorToMessage(error), icon: AppIcons.quiz),
            data: (examState) {
              if (examState.result != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.pushReplacement('/cbt/exam/$sessionKey/result');
                });
                return const Center(child: CupertinoActivityIndicator(radius: 14));
              }
              return _ExamBody(sessionKey: sessionKey, state: examState);
            },
          ),
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave exam?'),
        content: const Text('Your progress is saved automatically, but you have not submitted yet.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Stay')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

class _ExamBody extends ConsumerWidget {
  const _ExamBody({required this.sessionKey, required this.state});

  final String sessionKey;
  final ExamSessionState state;

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final question = state.currentQuestion;
    final subject = HiveSetup.subjectsBox.get(question.subjectId);
    final topic = question.topicId != null ? _topicNameOf(question.subjectId, question.topicId!) : null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(AppIcons.list),
                tooltip: 'Questions',
                onPressed: () => _openQuestionNavigator(context, ref),
              ),
              Expanded(
                child: Text(
                  'Question ${state.currentIndex + 1} of ${state.totalQuestions}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton(
                icon: const Icon(AppIcons.calculator),
                tooltip: 'Calculator',
                onPressed: () => showCalculatorSheet(context),
              ),
              if (state.isTimed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: (state.remainingSeconds ?? 0) < 60
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(_formatDuration(state.remainingSeconds ?? 0), style: theme.textTheme.labelLarge),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: QuestionCard(
              key: ValueKey(question.id),
              question: question,
              subjectName: subject?.name ?? 'Subject',
              topicName: topic,
              questionNumber: state.currentIndex + 1,
              selectedAnswer: state.answers[question.id],
              onAnswerChanged: (value) =>
                  ref.read(examSessionControllerProvider(sessionKey).notifier).answer(question.id, value),
              isBookmarked: state.bookmarkedIds.contains(question.id),
              onToggleBookmark: () =>
                  ref.read(examSessionControllerProvider(sessionKey).notifier).toggleBookmark(question.id),
              onAskAi: () => showQuestionExplanationSheet(context, ref, question.id),
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.currentIndex > 0
                      ? () => ref.read(examSessionControllerProvider(sessionKey).notifier).previous()
                      : null,
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (state.currentIndex < state.totalQuestions - 1)
                Expanded(
                  child: FilledButton(
                    onPressed: () => ref.read(examSessionControllerProvider(sessionKey).notifier).next(),
                    child: const Text('Next'),
                  ),
                )
              else
                Expanded(
                  child: FilledButton(
                    onPressed: () => _confirmSubmit(context, ref),
                    child: const Text('Submit'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmSubmit(BuildContext context, WidgetRef ref) {
    final unanswered = state.totalQuestions - state.answeredCount;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit exam?'),
        content: Text(
          unanswered > 0
              ? 'You have $unanswered unanswered question(s). Submit anyway?'
              : 'You have answered every question. Submit now?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(examSessionControllerProvider(sessionKey).notifier).submit();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _openQuestionNavigator(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _QuestionNavigatorSheet(sessionKey: sessionKey, state: state),
    );
  }
}

class _QuestionNavigatorSheet extends ConsumerWidget {
  const _QuestionNavigatorSheet({required this.sessionKey, required this.state});

  final String sessionKey;
  final ExamSessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final startIndexes = state.subjectStartIndexes;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shrinkWrap: true,
          children: [
            Text('Questions', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            for (final subjectId in state.subjectIds) ...[
              Text(
                HiveSetup.subjectsBox.get(subjectId)?.name ?? 'Subject',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (var i = 0; i < (state.questionsBySubject[subjectId]?.length ?? 0); i++)
                    _QuestionChip(
                      index: (startIndexes[subjectId] ?? 0) + i,
                      question: state.questionsBySubject[subjectId]![i],
                      state: state,
                      onTap: () {
                        Navigator.of(context).pop();
                        ref
                            .read(examSessionControllerProvider(sessionKey).notifier)
                            .jumpTo((startIndexes[subjectId] ?? 0) + i);
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

String? _topicNameOf(int subjectId, int topicId) {
  final subject = HiveSetup.subjectsBox.get(subjectId);
  if (subject == null) return null;
  for (final topic in subject.topics) {
    if (topic.id == topicId) return topic.name;
  }
  return null;
}

class _QuestionChip extends StatelessWidget {
  const _QuestionChip({required this.index, required this.question, required this.state, required this.onTap});

  final int index;
  final QuestionModel question;
  final ExamSessionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrent = index == state.currentIndex;
    final isAnswered = (state.answers[question.id] ?? '').isNotEmpty;
    final isBookmarked = state.bookmarkedIds.contains(question.id);

    Color background;
    Color foreground;
    if (isCurrent) {
      background = theme.colorScheme.primary;
      foreground = theme.colorScheme.onPrimary;
    } else if (isAnswered) {
      background = theme.colorScheme.primaryContainer;
      foreground = theme.colorScheme.onPrimaryContainer;
    } else {
      background = theme.colorScheme.surfaceContainerHighest;
      foreground = theme.colorScheme.onSurfaceVariant;
    }

    return InkWell(
      borderRadius: AppRadius.smRadius,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.smRadius,
          border: isBookmarked ? Border.all(color: theme.colorScheme.tertiary, width: 2) : null,
        ),
        child: Text('${index + 1}', style: theme.textTheme.labelLarge?.copyWith(color: foreground)),
      ),
    );
  }
}


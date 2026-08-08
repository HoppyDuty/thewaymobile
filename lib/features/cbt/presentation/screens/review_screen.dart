import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/hive_setup.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../shepherd/presentation/widgets/ask_shepherd_sheet.dart';
import '../providers/exam_session_controller.dart';
import '../widgets/question_card.dart';

/// Corrections view — every question, grouped by subject, with the correct
/// option highlighted and an AI button per question so the user can ask
/// Shepherd about anything they got wrong.
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, required this.sessionKey});

  final String sessionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examSessionControllerProvider(sessionKey)).valueOrNull;

    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Answers')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          for (final subjectId in state.subjectIds) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                HiveSetup.subjectsBox.get(subjectId)?.name ?? 'Subject',
                style: theme.textTheme.titleLarge,
              ),
            ),
            for (final question in state.questionsBySubject[subjectId] ?? const [])
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: QuestionCard(
                  question: question,
                  subjectName: HiveSetup.subjectsBox.get(subjectId)?.name ?? 'Subject',
                  questionNumber: (state.questionsBySubject[subjectId] ?? const []).indexOf(question) + 1,
                  selectedAnswer: state.answers[question.id],
                  showCorrection: true,
                  onAskAi: () => showQuestionExplanationSheet(context, ref, question.id),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

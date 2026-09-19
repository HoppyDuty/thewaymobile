import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/storage/hive_setup.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../shepherd/presentation/widgets/ask_shepherd_sheet.dart';
import '../../data/models/question_model.dart';
import '../providers/bookmarks_controller.dart';
import '../widgets/question_card.dart';

/// "My Questions" — every question the user has bookmarked, grouped by
/// subject, each with an AI button. Works offline as long as both the
/// bookmark-id list and the question bank have synced at least once.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarksControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Questions')),
      body: state.when(
        loading: () => AppShimmer(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 5,
            itemBuilder: (context, index) => const Card(child: SizedBox(height: 120)),
          ),
        ),
        error: (error, _) => AppErrorState(
          message: mapErrorToMessage(error),
          onRetry: () => ref.invalidate(bookmarksControllerProvider),
        ),
        data: (questions) {
          if (questions.isEmpty) {
            return const AppEmptyState(
              title: 'No bookmarked questions yet',
              message: 'Tap the bookmark icon on any question during an exam to save it here.',
              icon: AppIcons.bookmark,
            );
          }

          final bySubject = <int, List<QuestionModel>>{};
          for (final q in questions) {
            bySubject.putIfAbsent(q.subjectId, () => []).add(q);
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(bookmarksControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                for (final entry in bySubject.entries) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Text(
                      HiveSetup.subjectsBox.get(entry.key)?.name ?? 'Subject',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  for (final question in entry.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: QuestionCard(
                        question: question,
                        subjectName: HiveSetup.subjectsBox.get(entry.key)?.name ?? 'Subject',
                        isBookmarked: true,
                        onToggleBookmark: () =>
                            ref.read(bookmarksControllerProvider.notifier).removeBookmark(question.id),
                        onAskAi: () => showQuestionExplanationSheet(context, ref, question.id),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

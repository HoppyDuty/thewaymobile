import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../providers/profile_controller.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Stats')),
      body: state.when(
        loading: () => AppShimmer(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.3,
            ),
            itemCount: 8,
            itemBuilder: (context, index) =>
                Container(decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.lgRadius)),
          ),
        ),
        error: (error, _) => AppErrorState(
          message: mapErrorToMessage(error),
          onRetry: () => ref.invalidate(profileControllerProvider),
        ),
        data: (profile) {
          final stats = profile.stats;
          final tiles = [
            (icon: Icons.quiz_outlined, label: 'Exams Taken', value: '${stats.totalExamsTaken}'),
            (icon: Icons.check_circle_outline, label: 'Questions Answered', value: '${stats.totalQuestionsAnswered}'),
            (icon: Icons.trending_up, label: 'Average Score', value: '${stats.averageScorePercent.toStringAsFixed(1)}%'),
            (icon: Icons.star_outline, label: 'Best Score', value: '${stats.bestScorePercent.toStringAsFixed(1)}%'),
            (icon: Icons.schedule_outlined, label: 'Study Time', value: stats.totalStudyTimeLabel),
            (icon: Icons.local_fire_department_outlined, label: 'Current Streak', value: '${stats.currentStreakDays}d'),
            (icon: Icons.emoji_events_outlined, label: 'Longest Streak', value: '${stats.longestStreakDays}d'),
            (icon: Icons.play_circle_outline, label: 'Videos Watched', value: '${stats.videosWatched}'),
            (icon: Icons.video_library_outlined, label: 'Courses Enrolled', value: '${stats.coursesEnrolled}'),
            (icon: Icons.menu_book_outlined, label: 'Books Read', value: '${stats.booksRead}'),
            (icon: Icons.library_books_outlined, label: 'Books Completed', value: '${stats.booksCompleted}'),
            (icon: Icons.download_outlined, label: 'Books Saved Offline', value: '${stats.booksSavedOffline}'),
          ];

          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.3,
            ),
            itemCount: tiles.length,
            itemBuilder: (context, index) {
              final tile = tiles[index];
              final theme = Theme.of(context);
              return Card(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(tile.icon, color: theme.colorScheme.primary),
                      Text(tile.value, style: theme.textTheme.headlineSmall),
                      Text(tile.label, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

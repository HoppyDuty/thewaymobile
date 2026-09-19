import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
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
            (icon: AppIcons.quiz, label: 'Exams Taken', value: '${stats.totalExamsTaken}'),
            (icon: AppIcons.success, label: 'Questions Answered', value: '${stats.totalQuestionsAnswered}'),
            (icon: AppIcons.trending, label: 'Average Score', value: '${stats.averageScorePercent.toStringAsFixed(1)}%'),
            (icon: AppIcons.star, label: 'Best Score', value: '${stats.bestScorePercent.toStringAsFixed(1)}%'),
            (icon: AppIcons.clock, label: 'Study Time', value: stats.totalStudyTimeLabel),
            (icon: AppIcons.practice, label: 'Current Streak', value: '${stats.currentStreakDays}d'),
            (icon: AppIcons.trophy, label: 'Longest Streak', value: '${stats.longestStreakDays}d'),
            (icon: AppIcons.playOutline, label: 'Videos Watched', value: '${stats.videosWatched}'),
            (icon: AppIcons.video, label: 'Courses Enrolled', value: '${stats.coursesEnrolled}'),
            (icon: AppIcons.book, label: 'Books Read', value: '${stats.booksRead}'),
            (icon: AppIcons.library, label: 'Books Completed', value: '${stats.booksCompleted}'),
            (icon: AppIcons.download, label: 'Books Saved Offline', value: '${stats.booksSavedOffline}'),
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

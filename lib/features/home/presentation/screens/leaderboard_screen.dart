import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/leaderboard.dart';
import '../providers/leaderboard_controller.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  static const _medalColors = {1: Color(0xFFFFD700), 2: Color(0xFFC0C0C0), 3: Color(0xFFCD7F32)};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaderboardControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: state.when(
        loading: () => AppShimmer(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 8,
            itemBuilder: (context, index) => const ShimmerListTile(),
          ),
        ),
        error: (error, _) => AppErrorState(
          message: mapErrorToMessage(error),
          onRetry: () => ref.invalidate(leaderboardControllerProvider),
        ),
        data: (leaderboard) {
          if (leaderboard.top.isEmpty) {
            return const AppEmptyState(
              title: 'No rankings yet',
              message: 'Complete a CBT exam to appear on the leaderboard.',
              icon: AppIcons.leaderboard,
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(leaderboardControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                for (final entry in leaderboard.top) _LeaderboardTile(entry: entry, medalColors: _medalColors),
                if (leaderboard.myEntry != null && leaderboard.myEntry!.rank > leaderboard.top.length) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Divider(),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: AppRadius.mdRadius,
                    ),
                    child: _LeaderboardTile(entry: leaderboard.myEntry!, medalColors: _medalColors, isMe: true),
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

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry, required this.medalColors, this.isMe = false});

  final LeaderboardEntry entry;
  final Map<int, Color> medalColors;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medalColor = medalColors[entry.rank];

    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: medalColor ?? theme.colorScheme.surfaceContainerHighest,
        child: Text(
          '${entry.rank}',
          style: theme.textTheme.labelLarge?.copyWith(color: medalColor != null ? Colors.black87 : null),
        ),
      ),
      title: Row(
        children: [
          if (entry.user != null) ...[
            ClipOval(child: AppNetworkImage(url: entry.user!.avatarUrl, width: 32, height: 32)),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              isMe ? 'You' : (entry.user?.name ?? 'Student'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
      subtitle: Text('${entry.examsCompleted} exams · ${entry.avgScorePercent.toStringAsFixed(1)}% avg'),
      trailing: Text('${entry.totalScore.toStringAsFixed(0)} pts', style: theme.textTheme.titleSmall),
    );
  }
}

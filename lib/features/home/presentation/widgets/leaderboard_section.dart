import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../data/models/leaderboard.dart';

class LeaderboardSection extends StatelessWidget {
  const LeaderboardSection({super.key, required this.leaderboard});

  final Leaderboard leaderboard;

  @override
  Widget build(BuildContext context) {
    if (leaderboard.top.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: 'Leaderboard', onViewAll: () => context.push('/profile/leaderboard')),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: AppRadius.lgRadius,
          ),
          child: Column(
            children: [
              for (final entry in leaderboard.top.take(5))
                ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: entry.rank <= 3
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    child: Text('${entry.rank}', style: theme.textTheme.labelMedium),
                  ),
                  title: Row(
                    children: [
                      ClipOval(child: AppNetworkImage(url: entry.user?.avatarUrl, width: 28, height: 28)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          entry.user?.name ?? 'Student',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text('${entry.totalScore.toStringAsFixed(0)} pts', style: theme.textTheme.labelMedium),
                ),
              if (leaderboard.myEntry != null) ...[
                const Divider(height: 1),
                ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Text('${leaderboard.myEntry!.rank}', style: theme.textTheme.labelMedium),
                  ),
                  title: const Text('You'),
                  trailing: Text('${leaderboard.myEntry!.totalScore.toStringAsFixed(0)} pts'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

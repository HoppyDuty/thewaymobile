import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_colors.dart';
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

          // The top 3 get a distinct podium treatment; everyone else is a
          // normal ranked list underneath — a flat list of 10+ identically
          // styled rows buried who's actually excelling.
          final podium = leaderboard.top.where((e) => e.rank <= 3).toList();
          final rest = leaderboard.top.where((e) => e.rank > 3).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(leaderboardControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (podium.isNotEmpty) ...[
                  _PodiumSection(entries: podium),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Divider(),
                  ),
                ],
                for (final entry in rest) _LeaderboardTile(entry: entry),
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
                    child: _LeaderboardTile(entry: leaderboard.myEntry!, isMe: true),
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

/// 1st/2nd/3rd rendered as an actual podium — 1st raised in the centre with
/// the largest avatar and a gold treatment, 2nd/3rd flanking at a shorter
/// height in silver/bronze. `UI_UX_RULES.md`'s "one deliberate accent per
/// screen" — gold here is reserved for the #1 spot specifically, not
/// smeared across all three.
class _PodiumSection extends StatelessWidget {
  const _PodiumSection({required this.entries});

  final List<LeaderboardEntry> entries;

  LeaderboardEntry? _byRank(int rank) {
    for (final e in entries) {
      if (e.rank == rank) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final first = _byRank(1);
    final second = _byRank(2);
    final third = _byRank(3);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null)
            Expanded(child: _PodiumPlace(entry: second, style: _PodiumStyle.silver, barHeight: 64))
          else
            const Spacer(),
          if (first != null)
            Expanded(
              flex: 2,
              child: _PodiumPlace(entry: first, style: _PodiumStyle.gold, barHeight: 92),
            )
          else
            const Spacer(flex: 2),
          if (third != null)
            Expanded(child: _PodiumPlace(entry: third, style: _PodiumStyle.bronze, barHeight: 48))
          else
            const Spacer(),
        ],
      ),
    );
  }
}

enum _PodiumStyle { gold, silver, bronze }

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({required this.entry, required this.style, required this.barHeight});

  final LeaderboardEntry entry;
  final _PodiumStyle style;
  final double barHeight;

  ({Color base, Color onBase, Color bar}) _colors() {
    switch (style) {
      case _PodiumStyle.gold:
        return (base: AppColors.gold500, onBase: AppColors.gold900, bar: AppColors.gold400);
      case _PodiumStyle.silver:
        return (base: const Color(0xFFC7CCD1), onBase: const Color(0xFF3A3F44), bar: const Color(0xFFB0B6BC));
      case _PodiumStyle.bronze:
        return (base: const Color(0xFFCE8E5C), onBase: const Color(0xFF4A2E15), bar: const Color(0xFFBD7C48));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colors();
    final avatarSize = style == _PodiumStyle.gold ? 64.0 : 52.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (style == _PodiumStyle.gold) ...[
          Icon(AppIcons.trophy, color: AppColors.gold500, size: 22),
          const SizedBox(height: 4),
        ],
        Container(
          width: avatarSize + 8,
          height: avatarSize + 8,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(shape: BoxShape.circle, color: colors.base),
          child: ClipOval(
            child: entry.user != null
                ? AppNetworkImage(url: entry.user!.avatarUrl, width: avatarSize, height: avatarSize)
                : Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(AppIcons.leaderboard, color: theme.colorScheme.onSurfaceVariant),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          entry.user?.name ?? 'Student',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          '${entry.totalScore.toStringAsFixed(0)} pts',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          height: barHeight,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            color: colors.bar,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            '${entry.rank}',
            style: theme.textTheme.headlineSmall?.copyWith(color: colors.onBase, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry, this.isMe = false});

  final LeaderboardEntry entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Text('${entry.rank}', style: theme.textTheme.labelLarge),
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

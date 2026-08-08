import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../auth/presentation/providers/auth_session_controller.dart';
import '../../data/models/profile_models.dart';
import '../providers/profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can log back in any time.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Log Out')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authSessionControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: state.when(
        loading: () => AppShimmer(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const CircleAvatar(radius: 40),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < 6; i++) const ShimmerListTile(),
            ],
          ),
        ),
        error: (error, _) => AppErrorState(
          message: mapErrorToMessage(error),
          onRetry: () => ref.invalidate(profileControllerProvider),
        ),
        data: (profile) => RefreshIndicator(
          onRefresh: () => ref.read(profileControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _ProfileHeader(user: profile.user),
              const SizedBox(height: AppSpacing.lg),
              _StatsSummaryRow(stats: profile.stats),
              const SizedBox(height: AppSpacing.lg),
              _MenuSection(),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: () => _confirmLogout(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: () => context.push('/profile/delete-account'),
                icon: Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
                label: Text('Delete Account', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final ProfileUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        ClipOval(child: AppNetworkImage(url: user.avatarUrl, width: 72, height: 72)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.fullName, style: theme.textTheme.titleLarge),
              Text(user.email, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              Text(
                'Member since ${user.memberSince.year}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit profile',
          onPressed: () => context.push('/profile/edit'),
        ),
      ],
    );
  }
}

class _StatsSummaryRow extends StatelessWidget {
  const _StatsSummaryRow({required this.stats});

  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatTile(label: 'Exams', value: '${stats.totalExamsTaken}')),
        Expanded(child: _StatTile(label: 'Avg Score', value: '${stats.averageScorePercent.toStringAsFixed(0)}%')),
        Expanded(child: _StatTile(label: 'Streak', value: '${stats.currentStreakDays}🔥')),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          children: [
            Text(value, style: theme.textTheme.titleLarge),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection();

  static const _items = [
    (icon: Icons.bar_chart_outlined, label: 'My Stats', route: '/profile/stats'),
    (icon: Icons.shopping_bag_outlined, label: 'My Purchases', route: '/profile/purchases'),
    (icon: Icons.receipt_long_outlined, label: 'Payment History', route: '/profile/payments'),
    (icon: Icons.leaderboard_outlined, label: 'Leaderboard', route: '/profile/leaderboard'),
    (icon: Icons.settings_outlined, label: 'Preferences', route: '/profile/preferences'),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      child: Column(
        children: [
          for (final item in _items)
            ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(item.route),
            ),
        ],
      ),
    );
  }
}

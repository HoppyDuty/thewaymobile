import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
import '../../data/services/sync_manager.dart';
import '../providers/pending_sync_count_controller.dart';

/// Shows the CBT offline-sync state: a spinner while `SyncManager` is
/// actively flushing the queue, otherwise a badge with the count of
/// still-pending operations (queued exam submissions, bookmark toggles).
/// Hidden entirely when there's nothing pending and nothing in flight —
/// most users online most of the time should never see this at all.
class SyncBadge extends ConsumerWidget {
  const SyncBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;
    final isSyncing = ref.watch(syncManagerProvider).isLoading;

    if (pendingCount == 0 && !isSyncing) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return IconButton(
      tooltip: isSyncing
          ? 'Syncing…'
          : '$pendingCount item(s) waiting to sync — tap to retry now',
      onPressed: isSyncing ? null : () => ref.read(syncManagerProvider.notifier).syncNow(),
      icon: Badge(
        isLabelVisible: !isSyncing && pendingCount > 0,
        label: Text('$pendingCount'),
        child: isSyncing
            ? CupertinoActivityIndicator(radius: 9, color: theme.colorScheme.onSurfaceVariant)
            : Icon(AppIcons.sync, color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/notification_model.dart';
import '../providers/notifications_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          state.maybeWhen(
            data: (data) => data.unreadCount > 0
                ? TextButton(
                    onPressed: () => ref.read(notificationsControllerProvider.notifier).markAllRead(),
                    child: const Text('Mark all read'),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: state.when(
        loading: () => AppShimmer(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 6,
            itemBuilder: (context, index) => const ShimmerListTile(),
          ),
        ),
        error: (error, _) => AppErrorState(
          message: mapErrorToMessage(error),
          onRetry: () => ref.invalidate(notificationsControllerProvider),
        ),
        data: (data) {
          if (data.items.isEmpty) {
            return const AppEmptyState(
              title: 'No notifications yet',
              message: "We'll let you know when something needs your attention.",
              icon: AppIcons.notification,
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: data.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final NotificationModel notification = data.items[index];
                return ListTile(
                  tileColor: notification.isRead ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      notification.isRead ? AppIcons.notification : AppIcons.notificationActive,
                      color: notification.isRead ? theme.colorScheme.outline : theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(notification.title, style: theme.textTheme.titleSmall),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(DateFormat.MMMd().add_jm().format(notification.createdAt), style: theme.textTheme.labelSmall),
                    ],
                  ),
                  onTap: notification.isRead
                      ? null
                      : () => ref.read(notificationsControllerProvider.notifier).markRead(notification.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

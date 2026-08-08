import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/greeting.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.greeting, required this.unreadNotifications});

  final Greeting greeting;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: ClipOval(
              child: AppNetworkImage(url: greeting.avatarUrl, width: 48, height: 48),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${greeting.greeting}, ${greeting.name}',
                style: theme.textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "Let's keep learning today",
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push('/notifications'),
          tooltip: unreadNotifications > 0 ? 'Notifications ($unreadNotifications unread)' : 'Notifications',
          icon: Badge(
            isLabelVisible: unreadNotifications > 0,
            label: Text('$unreadNotifications'),
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../data/models/continue_learning_item.dart';

String _routeFor(ContinueLearningItem item) {
  return switch (item.entityType) {
    'video' => '/videos/${item.entityId}',
    'book' => '/books/${item.entityId}',
    _ => '/cbt/sessions/${item.entityId}',
  };
}

IconData _iconFor(String entityType) {
  return switch (entityType) {
    'video' => AppIcons.video,
    'book' => AppIcons.book,
    _ => AppIcons.cbt,
  };
}

class ContinueLearningSection extends StatelessWidget {
  const ContinueLearningSection({super.key, required this.items});

  final List<ContinueLearningItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Continue Learning'),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              return SizedBox(
                width: 140,
                child: InkWell(
                  borderRadius: AppRadius.mdRadius,
                  onTap: () => context.push(_routeFor(item)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          AppNetworkImage(
                            url: item.thumbnail,
                            width: 140,
                            height: 90,
                            borderRadius: AppRadius.mdRadius,
                          ),
                          if (item.thumbnail == null)
                            Positioned.fill(
                              child: Center(child: Icon(_iconFor(item.entityType), color: theme.colorScheme.primary)),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (item.progressPercent / 100).clamp(0, 1).toDouble(),
                          minHeight: 4,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

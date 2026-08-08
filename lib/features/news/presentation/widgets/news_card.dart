import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/news_summary.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.news});

  final NewsSummary news;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: AppRadius.mdRadius,
      onTap: () => context.push('/news/${news.slug}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppNetworkImage(url: news.thumbnail, width: 88, height: 72, borderRadius: AppRadius.mdRadius),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(news.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  if (news.excerpt != null)
                    Text(
                      news.excerpt!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        news.isLiked == true ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: news.isLiked == true ? theme.colorScheme.error : theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text('${news.likesCount}', style: theme.textTheme.labelSmall),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(Icons.chat_bubble_outline, size: 14, color: theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Text('${news.commentsCount}', style: theme.textTheme.labelSmall),
                      const Spacer(),
                      Text(DateFormat.MMMd().format(news.publishedAt), style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

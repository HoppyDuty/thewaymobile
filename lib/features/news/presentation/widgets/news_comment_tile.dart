import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/news_comment.dart';

class NewsCommentTile extends StatelessWidget {
  const NewsCommentTile({
    super.key,
    required this.comment,
    this.isReply = false,
    this.currentUserId,
    this.onDelete,
  });

  final NewsComment comment;
  final bool isReply;

  /// The signed-in user's id — the delete action only shows on the
  /// viewer's own comments.
  final int? currentUserId;
  final void Function(int commentId)? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwn = currentUserId != null && currentUserId == comment.user.id;

    return Padding(
      padding: EdgeInsets.only(left: isReply ? 40 : 0, top: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(child: AppNetworkImage(url: comment.user.avatarUrl, width: 32, height: 32)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(comment.user.name, style: theme.textTheme.labelLarge),
                        const SizedBox(width: AppSpacing.sm),
                        Text(DateFormat.MMMd().add_jm().format(comment.createdAt), style: theme.textTheme.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(comment.body, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              if (isOwn && onDelete != null)
                IconButton(
                  icon: const Icon(AppIcons.delete, size: 18),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Delete comment',
                  onPressed: () => _confirmDelete(context),
                ),
            ],
          ),
          for (final reply in comment.replies)
            NewsCommentTile(comment: reply, isReply: true, currentUserId: currentUserId, onDelete: onDelete),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete comment?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) onDelete?.call(comment.id);
  }
}

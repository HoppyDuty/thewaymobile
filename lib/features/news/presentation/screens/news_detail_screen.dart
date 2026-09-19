import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/notifications/snackbar_service.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_session_controller.dart';
import '../../../auth/presentation/providers/auth_session_state.dart';
import '../../data/news_api.dart';
import '../providers/news_comments_controller.dart';
import '../providers/news_detail_controller.dart';
import '../widgets/news_comment_tile.dart';

class NewsDetailScreen extends ConsumerStatefulWidget {
  const NewsDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends ConsumerState<NewsDetailScreen> {
  final _commentController = TextEditingController();
  bool _isPostingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment(int articleId) async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;

    setState(() => _isPostingComment = true);
    try {
      await ref.read(newsCommentsControllerProvider(articleId).notifier).addComment(body);
      ref.read(newsDetailControllerProvider(widget.slug).notifier).adjustCommentsCount(1);
      _commentController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      ref.read(snackbarServiceProvider).showError(mapErrorToMessage(e));
    } finally {
      if (mounted) setState(() => _isPostingComment = false);
    }
  }

  Future<void> _share(int articleId) async {
    try {
      final info = await ref.read(newsApiProvider).share(articleId);
      await SharePlus.instance.share(ShareParams(text: '${info.title}\n\n${info.excerpt ?? ''}\n\n${info.deepLink}'));
    } catch (e) {
      if (mounted) ref.read(snackbarServiceProvider).showError(mapErrorToMessage(e));
    }
  }

  Future<void> _shareToWhatsApp(int articleId) async {
    try {
      final info = await ref.read(newsApiProvider).share(articleId);
      await launchUrl(Uri.parse(info.whatsappUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) ref.read(snackbarServiceProvider).showError(mapErrorToMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final articleState = ref.watch(newsDetailControllerProvider(widget.slug));
    final theme = Theme.of(context);
    final authState = ref.watch(authSessionControllerProvider);
    final currentUserId = authState is AuthSessionAuthenticated ? authState.user.id : null;

    return Scaffold(
      appBar: AppBar(
        actions: [
          articleState.maybeWhen(
            data: (article) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _shareToWhatsApp(article.id),
                  icon: const Icon(AppIcons.chat),
                  tooltip: 'Share to WhatsApp',
                ),
                IconButton(
                  onPressed: () => _share(article.id),
                  icon: const Icon(AppIcons.share),
                  tooltip: 'Share',
                ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: articleState.when(
        loading: () => AppShimmer(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: const [
              ShimmerBox(height: 200, borderRadius: BorderRadius.all(Radius.circular(16))),
              SizedBox(height: AppSpacing.md),
              ShimmerBox(height: 24),
              SizedBox(height: AppSpacing.sm),
              ShimmerBox(height: 16),
            ],
          ),
        ),
        error: (error, _) => AppErrorState(
          message: mapErrorToMessage(error),
          onRetry: () => ref.invalidate(newsDetailControllerProvider(widget.slug)),
        ),
        data: (article) {
          final commentsState = ref.watch(newsCommentsControllerProvider(article.id));

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    if (article.imageUrl != null)
                      AppNetworkImage(
                        url: article.imageUrl,
                        height: 200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    Text(article.title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        ClipOval(child: AppNetworkImage(url: article.author.avatarUrl, width: 28, height: 28)),
                        const SizedBox(width: AppSpacing.sm),
                        Text(article.author.name, style: theme.textTheme.labelMedium),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Html(data: article.content),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => ref.read(newsDetailControllerProvider(widget.slug).notifier).toggleLike(),
                          tooltip: article.isLiked ? 'Unlike' : 'Like',
                          icon: Icon(
                            article.isLiked ? AppIcons.likeSelected : AppIcons.like,
                            color: article.isLiked ? theme.colorScheme.error : null,
                          ),
                        ),
                        Text('${article.likesCount}'),
                        const SizedBox(width: AppSpacing.md),
                        Icon(AppIcons.chat, size: 20, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('${article.commentsCount}'),
                      ],
                    ),
                    const Divider(height: AppSpacing.xl),
                    Text('Comments', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    commentsState.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Center(child: CupertinoActivityIndicator()),
                      ),
                      error: (e, _) => Text(mapErrorToMessage(e)),
                      data: (comments) => comments.items.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              child: Text(
                                'Be the first to comment.',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            )
                          : Column(children: [
                              for (final c in comments.items)
                                NewsCommentTile(
                                  comment: c,
                                  currentUserId: currentUserId,
                                  onDelete: (commentId) async {
                                    try {
                                      await ref
                                          .read(newsCommentsControllerProvider(article.id).notifier)
                                          .deleteComment(commentId);
                                      ref.read(newsDetailControllerProvider(widget.slug).notifier).adjustCommentsCount(-1);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ref.read(snackbarServiceProvider).showError(mapErrorToMessage(e));
                                      }
                                    }
                                  },
                                ),
                            ]),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppTextField(label: 'Add a comment...', controller: _commentController),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton.filled(
                        onPressed: _isPostingComment ? null : () => _postComment(article.id),
                        icon: _isPostingComment
                            ? const CupertinoActivityIndicator(radius: 9)
                            : const Icon(AppIcons.send),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

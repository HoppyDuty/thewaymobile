import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/news_comment.dart';
import '../../data/news_api.dart';

part 'news_comments_controller.g.dart';

class NewsCommentsState {
  const NewsCommentsState({required this.items, required this.hasMore});
  final List<NewsComment> items;
  final bool hasMore;
}

@riverpod
class NewsCommentsController extends _$NewsCommentsController {
  int _page = 1;

  @override
  Future<NewsCommentsState> build(int articleId) async {
    _page = 1;
    final result = await ref.watch(newsApiProvider).getComments(articleId, page: _page);
    return NewsCommentsState(items: result.items, hasMore: result.meta.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;

    final result = await ref.read(newsApiProvider).getComments(articleId, page: _page + 1);
    _page += 1;
    state = AsyncData(NewsCommentsState(items: [...current.items, ...result.items], hasMore: result.meta.hasMore));
  }

  Future<void> addComment(String body, {int? parentId}) async {
    final comment = await ref.read(newsApiProvider).addComment(articleId, body: body, parentId: parentId);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(NewsCommentsState(items: [comment, ...current.items], hasMore: current.hasMore));
  }

  Future<void> deleteComment(int commentId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Optimistic removal — a comment may be a top-level item or nested
    // inside another comment's `replies`.
    state = AsyncData(NewsCommentsState(
      items: _removeComment(current.items, commentId),
      hasMore: current.hasMore,
    ));

    try {
      await ref.read(newsApiProvider).deleteComment(articleId, commentId);
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }

  List<NewsComment> _removeComment(List<NewsComment> comments, int commentId) {
    return comments
        .where((c) => c.id != commentId)
        .map((c) => NewsComment(
              id: c.id,
              body: c.body,
              createdAt: c.createdAt,
              user: c.user,
              replies: _removeComment(c.replies, commentId),
            ))
        .toList();
  }
}

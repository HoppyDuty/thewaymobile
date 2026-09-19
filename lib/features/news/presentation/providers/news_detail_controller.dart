import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../home/presentation/providers/home_controller.dart';
import '../../data/models/news_article_detail.dart';
import '../../data/news_api.dart';
import 'news_list_controller.dart';

part 'news_detail_controller.g.dart';

@riverpod
class NewsDetailController extends _$NewsDetailController {
  @override
  Future<NewsArticleDetail> build(String slug) {
    return ref.watch(newsApiProvider).getArticle(slug);
  }

  /// Optimistic like toggle (`uiuxrules.md` §5 — immediate feedback for
  /// safe actions), rolled back if the request fails.
  ///
  /// Home's news preview and the View All list each hold their own snapshot
  /// of this article's like state with no shared cache between them — rather
  /// than refetching every endpoint on Home open, invalidate just those two
  /// targeted providers so they silently revalidate in the background
  /// (`seedAndRevalidate` shows their existing cached data immediately, no
  /// loading flash) instead of staying stale until a manual pull-to-refresh.
  Future<void> toggleLike() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final optimistic = current.copyWith(
      isLiked: !current.isLiked,
      likesCount: current.isLiked ? current.likesCount - 1 : current.likesCount + 1,
    );
    state = AsyncData(optimistic);

    try {
      final result = await ref.read(newsApiProvider).toggleLike(current.id);
      state = AsyncData(optimistic.copyWith(isLiked: result.isLiked, likesCount: result.likesCount));
      ref.invalidate(newsListControllerProvider);
      ref.invalidate(homeControllerProvider);
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }

  /// Called by the detail screen after a comment is successfully added or
  /// removed — keeps this article's own header count in sync without a
  /// network round-trip (the comment list itself is a separate provider,
  /// already updated by `NewsCommentsController`).
  void adjustCommentsCount(int delta) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(commentsCount: current.commentsCount + delta));
    ref.invalidate(newsListControllerProvider);
    ref.invalidate(homeControllerProvider);
  }
}

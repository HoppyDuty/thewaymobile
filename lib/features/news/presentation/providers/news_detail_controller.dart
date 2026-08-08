import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/news_article_detail.dart';
import '../../data/news_api.dart';

part 'news_detail_controller.g.dart';

@riverpod
class NewsDetailController extends _$NewsDetailController {
  @override
  Future<NewsArticleDetail> build(String slug) {
    return ref.watch(newsApiProvider).getArticle(slug);
  }

  /// Optimistic like toggle (`uiuxrules.md` §5 — immediate feedback for
  /// safe actions), rolled back if the request fails.
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
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }
}

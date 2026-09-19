import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/page_meta.dart';
import '../../../core/storage/offline_cache.dart';
import 'models/news_article_detail.dart';
import 'models/news_comment.dart';
import 'models/news_summary.dart';
import 'models/share_info.dart';

part 'news_api.g.dart';

class NewsApi {
  NewsApi(this._client, this._cache);

  final ApiClient _client;
  final OfflineCache _cache;

  /// `data` is a bare JSON array here (paginated) — see [ApiClient.getPage].
  /// Only page 1 is cached for offline fallback; deeper pages require a
  /// connection (consistent with `uiuxrules.md`'s pagination guidance —
  /// offline support matters most for the content a user sees immediately).
  Future<({List<NewsSummary> items, PageMeta meta})> list({int page = 1, int perPage = 15}) async {
    try {
      final envelope = await _client.getPage('/news', query: {'page': page, 'per_page': perPage});
      final items = envelope.list.map((e) => NewsSummary.fromJson(e as Map<String, dynamic>)).toList();
      if (page == 1) await _cache.write('news_list', envelope.list);
      return (items: items, meta: PageMeta.fromJson(envelope.meta));
    } on ApiException catch (e) {
      if (!e.isNetworkError || page != 1) rethrow;
      final cached = _cache.read('news_list');
      if (cached == null) rethrow;
      final items = tryParseCached(
        () => (cached.data as List).map((e) => NewsSummary.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      );
      if (items == null) rethrow;
      return (items: items, meta: const PageMeta(currentPage: 1, lastPage: 1, perPage: 15, total: 0, hasMore: false));
    }
  }

  /// Synchronous read of the cached first page — lets [NewsListController]
  /// paint immediately and revalidate in the background (`UI_UX_RULES.md`
  /// §11), same role as `HomeApi.readCachedHomeScreen`.
  List<NewsSummary>? readCachedList() {
    final cached = _cache.read('news_list');
    if (cached == null) return null;
    return tryParseCached(
      () => (cached.data as List).map((e) => NewsSummary.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    );
  }

  Future<NewsArticleDetail> getArticle(String slug) async {
    try {
      final data = await _client.get('/news/$slug');
      await _cache.write('news_article_$slug', data!);
      return NewsArticleDetail.fromJson(data);
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;
      final cached = _cache.read('news_article_$slug');
      if (cached == null) rethrow;
      final parsed = tryParseCached(() => NewsArticleDetail.fromJson(Map<String, dynamic>.from(cached.data as Map)));
      if (parsed == null) rethrow;
      return parsed;
    }
  }

  Future<({bool isLiked, int likesCount})> toggleLike(int articleId) async {
    final data = await _client.post('/news/$articleId/like');
    return (isLiked: data!['is_liked'] as bool, likesCount: data['likes_count'] as int);
  }

  Future<({List<NewsComment> items, PageMeta meta})> getComments(int articleId, {int page = 1}) async {
    final envelope = await _client.getPage('/news/$articleId/comments', query: {'page': page});
    final items = envelope.list.map((e) => NewsComment.fromJson(e as Map<String, dynamic>)).toList();
    return (items: items, meta: PageMeta.fromJson(envelope.meta));
  }

  Future<NewsComment> addComment(int articleId, {required String body, int? parentId}) async {
    final data = await _client.post('/news/$articleId/comments', data: {
      'body': body,
      if (parentId != null) 'parent_id': parentId,
    });
    return NewsComment.fromJson(data!);
  }

  Future<void> deleteComment(int articleId, int commentId) =>
      _client.delete('/news/$articleId/comments/$commentId');

  Future<ShareInfo> share(int articleId) async {
    final data = await _client.get('/news/$articleId/share');
    return ShareInfo.fromJson(data!);
  }
}

@Riverpod(keepAlive: true)
NewsApi newsApi(NewsApiRef ref) => NewsApi(ref.watch(apiClientProvider), ref.watch(offlineCacheProvider));

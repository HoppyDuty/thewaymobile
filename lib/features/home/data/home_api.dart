import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/page_meta.dart';
import '../../../core/storage/offline_cache.dart';
import 'models/continue_learning_item.dart';
import 'models/home_screen.dart';
import 'models/leaderboard.dart';
import 'models/recommended_course.dart';

part 'home_api.g.dart';

const _homeScreenCacheKey = 'home_screen';
const _leaderboardCacheKey = 'home_leaderboard';

class HomeApi {
  HomeApi(this._client, this._cache);

  final ApiClient _client;
  final OfflineCache _cache;

  /// Network-first, falling back to the last cached copy (kept for
  /// [OfflineCache.maxAge]) if there's no connection — the aggregate home
  /// payload is the one screen that must always show *something* offline.
  Future<HomeScreenData> getHomeScreen() async {
    try {
      final data = await _client.get('/home');
      await _cache.write(_homeScreenCacheKey, data!);
      return HomeScreenData.fromJson(data);
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;
      final cached = _cache.read(_homeScreenCacheKey);
      if (cached == null) rethrow;
      return HomeScreenData.fromJson(Map<String, dynamic>.from(cached.data as Map));
    }
  }

  /// Synchronous read of the last cached home payload (if any, within
  /// [OfflineCache.maxAge]) — lets [HomeController] paint it immediately
  /// and revalidate in the background instead of waiting on the network.
  HomeScreenData? readCachedHomeScreen() {
    final cached = _cache.read(_homeScreenCacheKey);
    if (cached == null) return null;
    return HomeScreenData.fromJson(Map<String, dynamic>.from(cached.data as Map));
  }

  Future<List<ContinueLearningItem>> getContinueLearning() async {
    final data = await _client.get('/home/continue-learning');
    return (data!['items'] as List<dynamic>)
        .map((e) => ContinueLearningItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `data` here is a bare JSON array (not `{items: [...]}`) since this
  /// endpoint is paginated — see [ApiClient.getPage].
  Future<({List<ContinueLearningItem> items, PageMeta meta})> getStudyHistory({int page = 1}) async {
    final envelope = await _client.getPage('/home/study-history', query: {'page': page});
    final items = envelope.list.map((e) => ContinueLearningItem.fromJson(e as Map<String, dynamic>)).toList();
    return (items: items, meta: PageMeta.fromJson(envelope.meta));
  }

  Future<List<RecommendedCourse>> getRecommendedCourses() async {
    final data = await _client.get('/home/recommended-courses');
    return (data!['courses'] as List<dynamic>)
        .map((e) => RecommendedCourse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Leaderboard> getLeaderboard() async {
    try {
      final data = await _client.get('/home/leaderboard');
      await _cache.write(_leaderboardCacheKey, data!);
      return Leaderboard.fromJson(data);
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;
      final cached = _cache.read(_leaderboardCacheKey);
      if (cached == null) rethrow;
      return Leaderboard.fromJson(Map<String, dynamic>.from(cached.data as Map));
    }
  }

  /// See [readCachedHomeScreen] — same immediate-paint role for
  /// [LeaderboardController].
  Leaderboard? readCachedLeaderboard() {
    final cached = _cache.read(_leaderboardCacheKey);
    if (cached == null) return null;
    return Leaderboard.fromJson(Map<String, dynamic>.from(cached.data as Map));
  }
}

@Riverpod(keepAlive: true)
HomeApi homeApi(HomeApiRef ref) => HomeApi(ref.watch(apiClientProvider), ref.watch(offlineCacheProvider));

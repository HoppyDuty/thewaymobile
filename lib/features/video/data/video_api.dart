import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/page_meta.dart';
import '../../../core/storage/offline_cache.dart';
import 'models/video_category.dart';
import 'models/video_course_detail.dart';
import 'models/video_course_summary.dart';
import 'models/video_download_models.dart';

part 'video_api.g.dart';

class VideoCoursePage {
  const VideoCoursePage({required this.items, required this.meta});
  final List<VideoCourseSummary> items;
  final PageMeta meta;
}

class VideoApi {
  VideoApi(this._client, this._cache);

  final ApiClient _client;
  final OfflineCache _cache;

  Future<List<VideoCategory>> getCategories() async {
    const cacheKey = 'video_categories';
    try {
      final data = await _client.get('/videos/categories');
      final categories = data?['categories'] as List<dynamic>? ?? [];
      await _cache.write(cacheKey, categories);
      return categories.map((c) => VideoCategory.fromJson(c as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;
      final cached = _cache.read(cacheKey);
      if (cached == null) rethrow;
      final parsed = tryParseCached(
        () => (cached.data as List<dynamic>).map((c) => VideoCategory.fromJson(Map<String, dynamic>.from(c))).toList(),
      );
      if (parsed == null) rethrow;
      return parsed;
    }
  }

  Future<VideoCoursePage> listCourses({int page = 1, int? categoryId}) async {
    final cacheKey = _coursesPageCacheKey(page, categoryId);
    try {
      final envelope = await _client.getPage(
        '/videos',
        query: {'page': page, if (categoryId != null) 'category_id': categoryId},
      );
      await _cache.write(cacheKey, {'items': envelope.list, 'meta': envelope.meta});
      return VideoCoursePage(
        items: envelope.list.map((c) => VideoCourseSummary.fromJson(c as Map<String, dynamic>)).toList(),
        meta: PageMeta.fromJson(envelope.meta),
      );
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;
      final cached = _cache.read(cacheKey);
      if (cached == null) rethrow;
      final parsed = tryParseCached(() {
        final map = Map<String, dynamic>.from(cached.data as Map);
        final items = (map['items'] as List<dynamic>).map((c) => VideoCourseSummary.fromJson(Map<String, dynamic>.from(c))).toList();
        return VideoCoursePage(items: items, meta: PageMeta.fromJson(map['meta'] as Map<String, dynamic>?));
      });
      if (parsed == null) rethrow;
      return parsed;
    }
  }

  /// Synchronous read of the cached first page for [categoryId] — lets
  /// [VideoCoursesController] paint immediately and revalidate in the
  /// background (`UI_UX_RULES.md` §11), same role as
  /// `HomeApi.readCachedHomeScreen`.
  VideoCoursePage? readCachedCourses(int? categoryId) {
    final cached = _cache.read(_coursesPageCacheKey(1, categoryId));
    if (cached == null) return null;
    return tryParseCached(() {
      final map = Map<String, dynamic>.from(cached.data as Map);
      final items =
          (map['items'] as List<dynamic>).map((c) => VideoCourseSummary.fromJson(Map<String, dynamic>.from(c))).toList();
      return VideoCoursePage(items: items, meta: PageMeta.fromJson(map['meta'] as Map<String, dynamic>?));
    });
  }

  String _coursesPageCacheKey(int page, int? categoryId) => 'video_courses_page_${page}_cat_${categoryId ?? ''}';

  Future<VideoCourseDetail> getCourse(String slug) async {
    final cacheKey = 'video_course_$slug';
    try {
      final data = await _client.get('/videos/$slug');
      await _cache.write(cacheKey, data!);
      return VideoCourseDetail.fromJson(data);
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;
      final cached = _cache.read(cacheKey);
      if (cached == null) rethrow;
      final parsed = tryParseCached(() => VideoCourseDetail.fromJson(Map<String, dynamic>.from(cached.data as Map)));
      if (parsed == null) rethrow;
      return parsed;
    }
  }

  Future<Map<String, dynamic>> saveProgress({
    required int lessonId,
    required int courseId,
    required int watchedSeconds,
    required int durationSeconds,
  }) async {
    final data = await _client.post(
      '/videos/lessons/$lessonId/progress',
      data: {'course_id': courseId, 'watched_seconds': watchedSeconds, 'duration_seconds': durationSeconds},
    );
    return data ?? {};
  }

  Future<DownloadRequestResult> requestDownload(int lessonId, {String quality = '720p'}) async {
    final data = await _client.post('/videos/lessons/$lessonId/download', data: {'quality': quality});
    return DownloadRequestResult.fromJson(data!);
  }

  Future<DownloadStatusResult> getDownloadStatus(String token) async {
    final data = await _client.get('/videos/downloads/$token/status');
    return DownloadStatusResult.fromJson(data!);
  }

  Future<List<MyDownloadItem>> getMyDownloads() async {
    final data = await _client.get('/videos/my-downloads');
    final downloads = data?['downloads'] as List<dynamic>? ?? [];
    return downloads.map((d) => MyDownloadItem.fromJson(d as Map<String, dynamic>)).toList();
  }
}

@Riverpod(keepAlive: true)
VideoApi videoApi(VideoApiRef ref) {
  return VideoApi(ref.watch(apiClientProvider), ref.watch(offlineCacheProvider));
}

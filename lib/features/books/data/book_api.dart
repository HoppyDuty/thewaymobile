import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/page_meta.dart';
import '../../../core/storage/offline_cache.dart';
import 'models/book_category.dart';
import 'models/book_detail.dart';
import 'models/book_download_models.dart';
import 'models/book_summary.dart';

part 'book_api.g.dart';

class BookPage {
  const BookPage({required this.items, required this.meta});
  final List<BookSummary> items;
  final PageMeta meta;
}

class BookApi {
  BookApi(this._client, this._cache);

  final ApiClient _client;
  final OfflineCache _cache;

  Future<List<BookCategory>> getCategories() async {
    const cacheKey = 'book_categories';
    try {
      final data = await _client.get('/books/categories');
      final categories = data?['categories'] as List<dynamic>? ?? [];
      await _cache.write(cacheKey, categories);
      return categories.map((c) => BookCategory.fromJson(c as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;
      final cached = _cache.read(cacheKey);
      if (cached == null) rethrow;
      return (cached.data as List<dynamic>).map((c) => BookCategory.fromJson(Map<String, dynamic>.from(c))).toList();
    }
  }

  Future<BookPage> listBooks({int page = 1, int? categoryId, int? authorId, String? search, String sortBy = 'sort_order'}) async {
    final cacheKey = 'books_page_${page}_cat_${categoryId ?? ''}_auth_${authorId ?? ''}_q_${search ?? ''}_sort_$sortBy';
    try {
      final envelope = await _client.getPage(
        '/books',
        query: {
          'page': page,
          'sort_by': sortBy,
          if (categoryId != null) 'category_id': categoryId,
          if (authorId != null) 'author_id': authorId,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      await _cache.write(cacheKey, {'items': envelope.list, 'meta': envelope.meta});
      return BookPage(
        items: envelope.list.map((b) => BookSummary.fromJson(b as Map<String, dynamic>)).toList(),
        meta: PageMeta.fromJson(envelope.meta),
      );
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;
      final cached = _cache.read(cacheKey);
      if (cached == null) rethrow;
      final map = Map<String, dynamic>.from(cached.data as Map);
      final items = (map['items'] as List<dynamic>).map((b) => BookSummary.fromJson(Map<String, dynamic>.from(b))).toList();
      return BookPage(items: items, meta: PageMeta.fromJson(map['meta'] as Map<String, dynamic>?));
    }
  }

  Future<BookDetail> getBook(String slug) async {
    final cacheKey = 'book_$slug';
    try {
      final data = await _client.get('/books/$slug');
      await _cache.write(cacheKey, data!);
      return BookDetail.fromJson(data);
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;
      final cached = _cache.read(cacheKey);
      if (cached == null) rethrow;
      return BookDetail.fromJson(Map<String, dynamic>.from(cached.data as Map));
    }
  }

  Future<BookReadingProgressResult> saveProgress({
    required int bookId,
    required int currentPage,
    required int totalPages,
  }) async {
    final data = await _client.post(
      '/books/$bookId/progress',
      data: {'current_page': currentPage, 'total_pages': totalPages},
    );
    return BookReadingProgressResult.fromJson(data!);
  }

  Future<SaveOfflineResult> saveOffline(int bookId) async {
    final data = await _client.post('/books/$bookId/save-offline');
    return SaveOfflineResult.fromJson(data!);
  }

  Future<List<MySavedBookItem>> getMySavedBooks() async {
    final data = await _client.get('/books/my-saved');
    final saved = data?['saved_books'] as List<dynamic>? ?? [];
    return saved.map((b) => MySavedBookItem.fromJson(b as Map<String, dynamic>)).toList();
  }
}

class BookReadingProgressResult {
  const BookReadingProgressResult({
    required this.currentPage,
    required this.totalPages,
    required this.progressPercent,
    required this.isCompleted,
  });

  final int currentPage;
  final int totalPages;
  final int progressPercent;
  final bool isCompleted;

  factory BookReadingProgressResult.fromJson(Map<String, dynamic> json) {
    return BookReadingProgressResult(
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 0,
      progressPercent: json['progress_percent'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}

@Riverpod(keepAlive: true)
BookApi bookApi(BookApiRef ref) {
  return BookApi(ref.watch(apiClientProvider), ref.watch(offlineCacheProvider));
}

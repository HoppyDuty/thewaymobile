import 'book_author.dart';
import 'book_category.dart';

class BookReadingProgress {
  const BookReadingProgress({
    required this.currentPage,
    required this.totalPages,
    required this.progressPercent,
    required this.isCompleted,
    required this.isSavedOffline,
    this.lastReadAt,
  });

  final int currentPage;
  final int totalPages;
  final int progressPercent;
  final bool isCompleted;
  final bool isSavedOffline;
  final String? lastReadAt;

  factory BookReadingProgress.fromJson(Map<String, dynamic> json) {
    return BookReadingProgress(
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 0,
      progressPercent: json['progress_percent'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      isSavedOffline: json['is_saved_offline'] as bool? ?? false,
      lastReadAt: json['last_read_at'] as String?,
    );
  }
}

class BookOfflineSaveInfo {
  const BookOfflineSaveInfo({required this.saveToken, required this.expiresAt, required this.daysRemaining});

  final String saveToken;
  final String expiresAt;
  final int daysRemaining;

  factory BookOfflineSaveInfo.fromJson(Map<String, dynamic> json) {
    return BookOfflineSaveInfo(
      saveToken: json['save_token'] as String,
      expiresAt: json['expires_at'] as String,
      daysRemaining: json['days_remaining'] as int? ?? 0,
    );
  }
}

class BookDetail {
  const BookDetail({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.coverUrl,
    this.pdfUrl,
    required this.pageCount,
    required this.price,
    this.isbn,
    this.publishedYear,
    required this.language,
    this.edition,
    this.fileSize,
    required this.fileSizeBytes,
    required this.readsCount,
    required this.downloadsCount,
    this.author,
    this.categories = const [],
    required this.hasAccess,
    required this.isFree,
    this.progress,
    this.offlineSave,
  });

  final int id;
  final String title;
  final String slug;
  final String? description;
  final String? coverUrl;

  /// Only present when [hasAccess] is true — the backend never sends this
  /// to a non-paying user (`BookService::getBookDetail()`).
  final String? pdfUrl;
  final int pageCount;
  final double price;
  final String? isbn;
  final int? publishedYear;
  final String language;
  final String? edition;
  final String? fileSize;
  final int fileSizeBytes;
  final int readsCount;
  final int downloadsCount;
  final BookAuthor? author;
  final List<BookCategory> categories;
  final bool hasAccess;
  final bool isFree;
  final BookReadingProgress? progress;
  final BookOfflineSaveInfo? offlineSave;

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    return BookDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      pageCount: json['page_count'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isbn: json['isbn'] as String?,
      publishedYear: json['published_year'] as int?,
      language: json['language'] as String? ?? 'en',
      edition: json['edition'] as String?,
      fileSize: json['file_size'] as String?,
      fileSizeBytes: json['file_size_bytes'] as int? ?? 0,
      readsCount: json['reads_count'] as int? ?? 0,
      downloadsCount: json['downloads_count'] as int? ?? 0,
      author: json['author'] != null ? BookAuthor.fromJson(json['author'] as Map<String, dynamic>) : null,
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((c) => BookCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
      hasAccess: json['has_access'] as bool? ?? false,
      isFree: json['is_free'] as bool? ?? false,
      progress: json['progress'] != null ? BookReadingProgress.fromJson(json['progress'] as Map<String, dynamic>) : null,
      offlineSave: json['offline_save'] != null
          ? BookOfflineSaveInfo.fromJson(json['offline_save'] as Map<String, dynamic>)
          : null,
    );
  }
}

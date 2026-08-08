import 'book_author.dart';
import 'book_category.dart';

/// One entry in the `/books` paginated list.
class BookSummary {
  const BookSummary({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.coverUrl,
    required this.pageCount,
    required this.price,
    this.fileSize,
    required this.fileSizeBytes,
    this.publishedYear,
    required this.language,
    this.edition,
    required this.readsCount,
    required this.downloadsCount,
    this.author,
    this.categories = const [],
    required this.hasAccess,
    required this.isFree,
    required this.progressPercent,
    required this.currentPage,
    required this.isCompleted,
  });

  final int id;
  final String title;
  final String slug;
  final String? description;
  final String? coverUrl;
  final int pageCount;
  final double price;
  final String? fileSize;
  final int fileSizeBytes;
  final int? publishedYear;
  final String language;
  final String? edition;
  final int readsCount;
  final int downloadsCount;
  final BookAuthor? author;
  final List<BookCategory> categories;
  final bool hasAccess;
  final bool isFree;
  final int progressPercent;
  final int currentPage;
  final bool isCompleted;

  factory BookSummary.fromJson(Map<String, dynamic> json) {
    return BookSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      pageCount: json['page_count'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      fileSize: json['file_size'] as String?,
      fileSizeBytes: json['file_size_bytes'] as int? ?? 0,
      publishedYear: json['published_year'] as int?,
      language: json['language'] as String? ?? 'en',
      edition: json['edition'] as String?,
      readsCount: json['reads_count'] as int? ?? 0,
      downloadsCount: json['downloads_count'] as int? ?? 0,
      author: json['author'] != null ? BookAuthor.fromJson(json['author'] as Map<String, dynamic>) : null,
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((c) => BookCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
      hasAccess: json['has_access'] as bool? ?? false,
      isFree: json['is_free'] as bool? ?? false,
      progressPercent: json['progress_percent'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}

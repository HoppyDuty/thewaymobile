/// Result of `POST /books/{bookId}/save-offline`.
class SaveOfflineResult {
  const SaveOfflineResult({
    required this.saveToken,
    required this.status,
    required this.pdfUrl,
    required this.expiresAt,
    required this.daysRemaining,
  });

  final String saveToken;
  final String status;

  /// The Cloudinary-hosted PDF URL — downloaded directly to local disk for
  /// offline reading (no custom file-streaming endpoint needed, unlike
  /// videos, since this is already a direct, fetchable file URL).
  final String pdfUrl;
  final String expiresAt;
  final int daysRemaining;

  factory SaveOfflineResult.fromJson(Map<String, dynamic> json) {
    return SaveOfflineResult(
      saveToken: json['save_token'] as String,
      status: json['status'] as String,
      pdfUrl: json['pdf_url'] as String,
      expiresAt: json['expires_at'] as String,
      daysRemaining: json['days_remaining'] as int? ?? 0,
    );
  }
}

class MySavedBookInfo {
  const MySavedBookInfo({
    required this.id,
    required this.title,
    required this.slug,
    this.coverUrl,
    required this.pageCount,
    required this.fileSizeBytes,
    this.authorName,
    required this.pdfUrl,
  });

  final int id;
  final String title;
  final String slug;
  final String? coverUrl;
  final int pageCount;
  final int fileSizeBytes;
  final String? authorName;
  final String pdfUrl;

  factory MySavedBookInfo.fromJson(Map<String, dynamic> json) {
    return MySavedBookInfo(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      coverUrl: json['cover_url'] as String?,
      pageCount: json['page_count'] as int? ?? 0,
      fileSizeBytes: json['file_size_bytes'] as int? ?? 0,
      authorName: json['author_name'] as String?,
      pdfUrl: json['pdf_url'] as String,
    );
  }
}

class MySavedBookItem {
  const MySavedBookItem({
    required this.saveToken,
    required this.expiresAt,
    required this.daysRemaining,
    required this.book,
  });

  final String saveToken;
  final String expiresAt;
  final int daysRemaining;
  final MySavedBookInfo book;

  factory MySavedBookItem.fromJson(Map<String, dynamic> json) {
    return MySavedBookItem(
      saveToken: json['save_token'] as String,
      expiresAt: json['expires_at'] as String,
      daysRemaining: json['days_remaining'] as int? ?? 0,
      book: MySavedBookInfo.fromJson(json['book'] as Map<String, dynamic>),
    );
  }
}

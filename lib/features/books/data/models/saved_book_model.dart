import 'package:hive_ce/hive.dart';

part 'saved_book_model.g.dart';

/// A book's PDF actually saved to local disk for fully offline reading —
/// mirrors `DownloadedVideoModel`'s role for the video feature. Lives in
/// Hive with no TTL; [isExpired] is checked against [expiresAt] (mirrors
/// the backend's 30-day `BookService::SAVE_EXPIRY_DAYS`) whenever the
/// saved-books list is read, and expired entries are cleaned up (file +
/// record) rather than just hidden.
@HiveType(typeId: 40)
class SavedBookModel extends HiveObject {
  SavedBookModel({
    required this.bookId,
    required this.slug,
    required this.title,
    this.coverUrl,
    this.authorName,
    required this.pageCount,
    required this.localFilePath,
    required this.fileSizeBytes,
    required this.savedAt,
    required this.expiresAt,
  });

  @HiveField(0)
  final int bookId;
  @HiveField(1)
  final String slug;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String? coverUrl;
  @HiveField(4)
  final String? authorName;
  @HiveField(5)
  final int pageCount;
  @HiveField(6)
  final String localFilePath;
  @HiveField(7)
  final int fileSizeBytes;

  /// Unix timestamp (seconds).
  @HiveField(8)
  final int savedAt;

  /// Unix timestamp (seconds) — mirrors the server's `expires_at` for this
  /// save token.
  @HiveField(9)
  final int expiresAt;

  bool get isExpired => DateTime.now().millisecondsSinceEpoch ~/ 1000 > expiresAt;

  int get daysRemaining {
    final remaining = expiresAt - (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    return remaining > 0 ? (remaining / 86400).ceil() : 0;
  }
}

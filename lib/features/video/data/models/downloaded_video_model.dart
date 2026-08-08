import 'package:hive_ce/hive.dart';

part 'downloaded_video_model.g.dart';

/// A lesson's video file actually saved to local disk — this is what makes
/// "My Videos" genuinely offline-playable rather than just a list of
/// server-side download records. Lives in Hive with no TTL; [isExpired]
/// is checked against [expiresAt] (mirrors the backend's 30-day
/// `VideoService::DOWNLOAD_EXPIRY_DAYS`) whenever the list is read, and
/// expired entries are cleaned up (file + record) rather than just hidden.
@HiveType(typeId: 30)
class DownloadedVideoModel extends HiveObject {
  DownloadedVideoModel({
    required this.lessonId,
    required this.courseId,
    required this.courseSlug,
    required this.title,
    this.thumbnailUrl,
    required this.durationSeconds,
    required this.quality,
    required this.localFilePath,
    required this.fileSizeBytes,
    required this.downloadedAt,
    required this.expiresAt,
  });

  @HiveField(0)
  final int lessonId;
  @HiveField(1)
  final int courseId;
  @HiveField(2)
  final String courseSlug;
  @HiveField(3)
  final String title;
  @HiveField(4)
  final String? thumbnailUrl;
  @HiveField(5)
  final int durationSeconds;
  @HiveField(6)
  final String quality;
  @HiveField(7)
  final String localFilePath;
  @HiveField(8)
  final int fileSizeBytes;

  /// Unix timestamp (seconds).
  @HiveField(9)
  final int downloadedAt;

  /// Unix timestamp (seconds) — mirrors the server's `expires_at` for this
  /// download token, so the local copy expires on the same schedule.
  @HiveField(10)
  final int expiresAt;

  bool get isExpired => DateTime.now().millisecondsSinceEpoch ~/ 1000 > expiresAt;

  int get daysRemaining {
    final remaining = expiresAt - (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    return remaining > 0 ? (remaining / 86400).ceil() : 0;
  }
}

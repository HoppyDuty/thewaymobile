/// Result of `POST /videos/lessons/{id}/download` — the backend names the
/// "days left" field differently depending on whether this is a brand-new
/// request (`expires_in_days`) or an already-completed download being
/// re-returned (`days_remaining`); both are read here under one name.
class DownloadRequestResult {
  const DownloadRequestResult({
    required this.downloadToken,
    required this.status,
    required this.expiresAt,
    required this.daysRemaining,
  });

  final String downloadToken;
  final String status;
  final String expiresAt;
  final int daysRemaining;

  factory DownloadRequestResult.fromJson(Map<String, dynamic> json) {
    return DownloadRequestResult(
      downloadToken: json['download_token'] as String,
      status: json['status'] as String,
      expiresAt: json['expires_at'] as String,
      daysRemaining: (json['days_remaining'] ?? json['expires_in_days']) as int? ?? 0,
    );
  }
}

class DownloadStatusResult {
  const DownloadStatusResult({
    required this.status,
    required this.expiresAt,
    required this.fileSizeBytes,
    this.downloadedAt,
  });

  final String status;
  final String expiresAt;
  final int fileSizeBytes;
  final String? downloadedAt;

  factory DownloadStatusResult.fromJson(Map<String, dynamic> json) {
    return DownloadStatusResult(
      status: json['status'] as String,
      expiresAt: json['expires_at'] as String,
      fileSizeBytes: json['file_size'] as int? ?? 0,
      downloadedAt: json['downloaded_at'] as String?,
    );
  }
}

class DownloadLessonInfo {
  const DownloadLessonInfo({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.durationSeconds,
    required this.durationLabel,
    required this.videoCourseId,
    required this.youtubeVideoId,
    required this.position,
  });

  final int id;
  final String title;
  final String? thumbnailUrl;
  final int durationSeconds;
  final String durationLabel;
  final int videoCourseId;
  final String youtubeVideoId;
  final int position;

  factory DownloadLessonInfo.fromJson(Map<String, dynamic> json) {
    return DownloadLessonInfo(
      id: json['id'] as int,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      durationLabel: json['duration_label'] as String? ?? '0:00',
      videoCourseId: json['video_course_id'] as int,
      youtubeVideoId: json['youtube_video_id'] as String,
      position: json['position'] as int? ?? 0,
    );
  }
}

class MyDownloadItem {
  const MyDownloadItem({
    required this.downloadToken,
    required this.expiresAt,
    required this.daysRemaining,
    required this.fileSizeBytes,
    required this.quality,
    required this.lesson,
  });

  final String downloadToken;
  final String expiresAt;
  final int daysRemaining;
  final int fileSizeBytes;
  final String quality;
  final DownloadLessonInfo lesson;

  factory MyDownloadItem.fromJson(Map<String, dynamic> json) {
    return MyDownloadItem(
      downloadToken: json['download_token'] as String,
      expiresAt: json['expires_at'] as String,
      daysRemaining: json['days_remaining'] as int? ?? 0,
      fileSizeBytes: json['file_size_bytes'] as int? ?? 0,
      quality: json['quality'] as String? ?? '720p',
      lesson: DownloadLessonInfo.fromJson(json['lesson'] as Map<String, dynamic>),
    );
  }
}

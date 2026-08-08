class VideoLesson {
  const VideoLesson({
    required this.id,
    required this.youtubeVideoId,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.durationSeconds,
    required this.durationLabel,
    required this.position,
    required this.isPlayable,
    required this.isFreePreview,
    required this.progressPercent,
    required this.watchedSeconds,
    required this.isCompleted,
  });

  final int id;
  final String youtubeVideoId;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final int durationSeconds;
  final String durationLabel;
  final int position;
  final bool isPlayable;
  final bool isFreePreview;
  final int progressPercent;
  final int watchedSeconds;
  final bool isCompleted;

  factory VideoLesson.fromJson(Map<String, dynamic> json) {
    return VideoLesson(
      id: json['id'] as int,
      youtubeVideoId: json['youtube_video_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      durationLabel: json['duration_label'] as String? ?? '0:00',
      position: json['position'] as int? ?? 0,
      isPlayable: json['is_playable'] as bool? ?? false,
      isFreePreview: json['is_free_preview'] as bool? ?? false,
      progressPercent: json['progress_percent'] as int? ?? 0,
      watchedSeconds: json['watched_seconds'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}

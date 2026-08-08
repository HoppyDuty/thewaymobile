import 'video_category.dart';

/// One entry in the `/videos` paginated list.
class VideoCourseSummary {
  const VideoCourseSummary({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.thumbnailUrl,
    required this.price,
    required this.videoCount,
    required this.duration,
    required this.totalSeconds,
    this.categories = const [],
    required this.hasAccess,
    required this.isFree,
    required this.progressPercent,
  });

  final int id;
  final String title;
  final String slug;
  final String? description;
  final String? thumbnailUrl;
  final double price;
  final int videoCount;
  final String duration;
  final int totalSeconds;
  final List<VideoCategory> categories;
  final bool hasAccess;
  final bool isFree;
  final int progressPercent;

  factory VideoCourseSummary.fromJson(Map<String, dynamic> json) {
    return VideoCourseSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      videoCount: json['video_count'] as int? ?? 0,
      duration: json['duration'] as String? ?? '0m',
      totalSeconds: json['total_seconds'] as int? ?? 0,
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((c) => VideoCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
      hasAccess: json['has_access'] as bool? ?? false,
      isFree: json['is_free'] as bool? ?? false,
      progressPercent: json['progress_percent'] as int? ?? 0,
    );
  }
}

import 'video_category.dart';
import 'video_lesson.dart';

class VideoCourseDetail {
  const VideoCourseDetail({
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
    required this.freePreviewCount,
    this.lessons = const [],
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
  final int freePreviewCount;
  final List<VideoLesson> lessons;

  bool get isFree => price == 0;

  factory VideoCourseDetail.fromJson(Map<String, dynamic> json) {
    return VideoCourseDetail(
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
      freePreviewCount: json['free_preview'] as int? ?? 5,
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .map((l) => VideoLesson.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

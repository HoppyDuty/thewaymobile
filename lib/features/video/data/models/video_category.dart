class VideoCategory {
  const VideoCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.colorHex,
    this.icon,
    this.coursesCount = 0,
  });

  final int id;
  final String name;
  final String slug;
  final String colorHex;
  final String? icon;
  final int coursesCount;

  factory VideoCategory.fromJson(Map<String, dynamic> json) {
    return VideoCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      colorHex: json['color_hex'] as String? ?? '#1a237e',
      icon: json['icon'] as String?,
      coursesCount: json['courses_count'] as int? ?? 0,
    );
  }
}

class RecommendedCourse {
  const RecommendedCourse({
    required this.id,
    required this.title,
    required this.slug,
    this.thumbnailUrl,
    required this.price,
    this.description,
  });

  final int id;
  final String title;
  final String slug;
  final String? thumbnailUrl;
  final num price;
  final String? description;

  factory RecommendedCourse.fromJson(Map<String, dynamic> json) {
    return RecommendedCourse(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      price: json['price'] as num? ?? 0,
      description: json['description'] as String?,
    );
  }
}

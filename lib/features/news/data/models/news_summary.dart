/// The list-item shape used by both `/home` (latest 5) and `/news`
/// (paginated list) — same fields except the home aggregate additionally
/// includes `is_liked`.
class NewsSummary {
  const NewsSummary({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.thumbnail,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    this.isLiked,
    required this.publishedAt,
  });

  final int id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? thumbnail;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool? isLiked;
  final DateTime publishedAt;

  factory NewsSummary.fromJson(Map<String, dynamic> json) {
    return NewsSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      excerpt: json['excerpt'] as String?,
      thumbnail: json['thumbnail'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool?,
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

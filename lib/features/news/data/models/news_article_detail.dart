class NewsAuthor {
  const NewsAuthor({required this.id, required this.name, this.avatarUrl});

  final int id;
  final String name;
  final String? avatarUrl;

  factory NewsAuthor.fromJson(Map<String, dynamic> json) {
    return NewsAuthor(
      id: json['id'] as int,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class NewsArticleDetail {
  const NewsArticleDetail({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.publishedAt,
    required this.author,
    required this.isLiked,
  });

  final int id;
  final String title;
  final String slug;
  final String? excerpt;

  /// HTML — render with a rich-text/HTML widget, not a plain [Text].
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final DateTime publishedAt;
  final NewsAuthor author;
  final bool isLiked;

  NewsArticleDetail copyWith({bool? isLiked, int? likesCount}) {
    return NewsArticleDetail(
      id: id,
      title: title,
      slug: slug,
      excerpt: excerpt,
      content: content,
      imageUrl: imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount,
      viewsCount: viewsCount,
      publishedAt: publishedAt,
      author: author,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory NewsArticleDetail.fromJson(Map<String, dynamic> json) {
    return NewsArticleDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      excerpt: json['excerpt'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? '') ?? DateTime.now(),
      author: NewsAuthor.fromJson(json['author'] as Map<String, dynamic>),
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }
}

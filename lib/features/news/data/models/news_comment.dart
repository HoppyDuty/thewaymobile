class NewsCommentAuthor {
  const NewsCommentAuthor({required this.id, required this.name, this.avatarUrl});

  final int id;
  final String name;
  final String? avatarUrl;

  factory NewsCommentAuthor.fromJson(Map<String, dynamic> json) {
    return NewsCommentAuthor(
      id: json['id'] as int,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class NewsComment {
  const NewsComment({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.user,
    this.replies = const [],
  });

  final int id;
  final String body;
  final DateTime createdAt;
  final NewsCommentAuthor user;
  final List<NewsComment> replies;

  factory NewsComment.fromJson(Map<String, dynamic> json) {
    return NewsComment(
      id: json['id'] as int,
      body: json['body'] as String,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      user: NewsCommentAuthor.fromJson(json['user'] as Map<String, dynamic>),
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((e) => NewsComment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

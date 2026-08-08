class BookAuthor {
  const BookAuthor({required this.id, required this.name, required this.slug, this.bio, this.avatarUrl});

  final int id;
  final String name;
  final String slug;
  final String? bio;
  final String? avatarUrl;

  factory BookAuthor.fromJson(Map<String, dynamic> json) {
    return BookAuthor(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

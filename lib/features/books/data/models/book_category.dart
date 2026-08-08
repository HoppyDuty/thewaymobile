class BookCategory {
  const BookCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.colorHex,
    this.icon,
    this.booksCount = 0,
  });

  final int id;
  final String name;
  final String slug;
  final String colorHex;
  final String? icon;
  final int booksCount;

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    return BookCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      colorHex: json['color_hex'] as String? ?? '#1a237e',
      icon: json['icon'] as String?,
      booksCount: json['books_count'] as int? ?? 0,
    );
  }
}

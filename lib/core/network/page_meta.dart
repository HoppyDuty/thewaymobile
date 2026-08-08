/// The pagination `meta` object shared by every paginated endpoint
/// (`current_page`, `last_page`, `per_page`, `total`, `has_more`).
class PageMeta {
  const PageMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  factory PageMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PageMeta(currentPage: 1, lastPage: 1, perPage: 0, total: 0, hasMore: false);
    }
    return PageMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
}

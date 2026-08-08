class CarouselSlide {
  const CarouselSlide({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.linkType,
    this.linkValue,
  });

  final int id;
  final String title;
  final String? subtitle;
  final String imageUrl;

  /// `internal` | `external` | `none`.
  final String linkType;
  final String? linkValue;

  factory CarouselSlide.fromJson(Map<String, dynamic> json) {
    return CarouselSlide(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String,
      linkType: json['link_type'] as String? ?? 'none',
      linkValue: json['link_value'] as String?,
    );
  }
}

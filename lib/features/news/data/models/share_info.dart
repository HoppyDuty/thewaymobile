class ShareInfo {
  const ShareInfo({
    required this.deepLink,
    required this.whatsappUrl,
    required this.title,
    this.excerpt,
    this.thumbnail,
  });

  final String deepLink;
  final String whatsappUrl;
  final String title;
  final String? excerpt;
  final String? thumbnail;

  factory ShareInfo.fromJson(Map<String, dynamic> json) {
    return ShareInfo(
      deepLink: json['deep_link'] as String,
      whatsappUrl: json['whatsapp_url'] as String,
      title: json['title'] as String,
      excerpt: json['excerpt'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );
  }
}

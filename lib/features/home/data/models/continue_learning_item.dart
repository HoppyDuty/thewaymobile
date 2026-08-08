/// Same shape is used for `/home/continue-learning` and the paginated
/// `/home/study-history` (both come from the `StudyHistory` model on the
/// backend — one filters `is_completed=false`, the other `=true`).
class ContinueLearningItem {
  const ContinueLearningItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.title,
    this.thumbnail,
    required this.progressPercent,
    required this.lastAccessedAt,
  });

  final int id;

  /// `cbt_session` | `video` | `book`.
  final String entityType;
  final int entityId;
  final String title;
  final String? thumbnail;
  final num progressPercent;
  final DateTime lastAccessedAt;

  factory ContinueLearningItem.fromJson(Map<String, dynamic> json) {
    return ContinueLearningItem(
      id: json['id'] as int,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as int,
      title: json['title'] as String,
      thumbnail: json['thumbnail'] as String?,
      progressPercent: json['progress_percent'] as num? ?? 0,
      lastAccessedAt: DateTime.tryParse(json['last_accessed_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

import 'package:hive_ce/hive.dart';

import 'hive_type_ids.dart';

part 'topic_model.g.dart';

@HiveType(typeId: kHiveTypeTopic)
class TopicModel {
  TopicModel({required this.id, required this.subjectId, required this.name, required this.slug});

  @HiveField(0)
  final int id;
  @HiveField(1)
  final int subjectId;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String slug;

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as int,
      subjectId: json['subject_id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }
}

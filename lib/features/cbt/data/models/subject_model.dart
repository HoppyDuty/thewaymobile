import 'package:hive_ce/hive.dart';

import 'hive_type_ids.dart';
import 'topic_model.dart';

part 'subject_model.g.dart';

@HiveType(typeId: kHiveTypeSubject)
class SubjectModel {
  SubjectModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.isEnglish,
    this.topics = const [],
  });

  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String slug;
  @HiveField(3)
  final bool isEnglish;
  @HiveField(4)
  final List<TopicModel> topics;

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      isEnglish: json['is_english'] as bool? ?? false,
      topics: (json['topics'] as List<dynamic>? ?? [])
          .map((e) => TopicModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

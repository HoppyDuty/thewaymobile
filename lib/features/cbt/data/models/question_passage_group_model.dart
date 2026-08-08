import 'package:hive_ce/hive.dart';

import 'hive_type_ids.dart';

part 'question_passage_group_model.g.dart';

/// A shared passage/register/literature extract that a block of
/// [QuestionModel]s (linked via `passageGroupId`) all refer to — matches the
/// `passage-groups` block of `CbtDeltaSyncService::getQuestionDelta()`.
@HiveType(typeId: kHiveTypePassageGroup)
class QuestionPassageGroupModel {
  QuestionPassageGroupModel({
    required this.id,
    required this.examTypeId,
    required this.subjectId,
    required this.type,
    this.passageTitle,
    required this.passageText,
    this.year,
  });

  @HiveField(0)
  final int id;
  @HiveField(1)
  final int examTypeId;
  @HiveField(2)
  final int subjectId;

  /// `comprehension` | `register` | `literature`.
  @HiveField(3)
  final String type;
  @HiveField(4)
  final String? passageTitle;
  @HiveField(5)
  final String passageText;
  @HiveField(6)
  final int? year;

  factory QuestionPassageGroupModel.fromJson(Map<String, dynamic> json) {
    return QuestionPassageGroupModel(
      id: json['id'] as int,
      examTypeId: json['exam_type_id'] as int,
      subjectId: json['subject_id'] as int,
      type: json['type'] as String? ?? 'comprehension',
      passageTitle: json['passage_title'] as String?,
      passageText: json['passage_text'] as String? ?? '',
      year: json['year'] as int?,
    );
  }
}

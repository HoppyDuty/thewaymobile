// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_passage_group_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionPassageGroupModelAdapter
    extends TypeAdapter<QuestionPassageGroupModel> {
  @override
  final typeId = 15;

  @override
  QuestionPassageGroupModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionPassageGroupModel(
      id: (fields[0] as num).toInt(),
      examTypeId: (fields[1] as num).toInt(),
      subjectId: (fields[2] as num).toInt(),
      type: fields[3] as String,
      passageTitle: fields[4] as String?,
      passageText: fields[5] as String,
      year: (fields[6] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestionPassageGroupModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.examTypeId)
      ..writeByte(2)
      ..write(obj.subjectId)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.passageTitle)
      ..writeByte(5)
      ..write(obj.passageText)
      ..writeByte(6)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionPassageGroupModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

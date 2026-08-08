// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionModelAdapter extends TypeAdapter<QuestionModel> {
  @override
  final typeId = 14;

  @override
  QuestionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionModel(
      id: (fields[0] as num).toInt(),
      examTypeId: (fields[1] as num).toInt(),
      subjectId: (fields[2] as num).toInt(),
      topicId: (fields[3] as num?)?.toInt(),
      year: (fields[4] as num?)?.toInt(),
      questionType: fields[5] as String,
      body: fields[6] as String,
      bodyImageUrl: fields[7] as String?,
      optionA: fields[8] as String?,
      optionAImageUrl: fields[9] as String?,
      optionB: fields[10] as String?,
      optionBImageUrl: fields[11] as String?,
      optionC: fields[12] as String?,
      optionCImageUrl: fields[13] as String?,
      optionD: fields[14] as String?,
      optionDImageUrl: fields[15] as String?,
      optionE: fields[16] as String?,
      optionEImageUrl: fields[17] as String?,
      correctOption: fields[18] as String?,
      correctAnswerText: fields[19] as String?,
      explanation: fields[20] as String?,
      explanationImageUrl: fields[21] as String?,
      specialType: fields[22] as String,
      passageGroupId: (fields[23] as num?)?.toInt(),
      passageOrder: (fields[24] as num?)?.toInt(),
      updatedAt: (fields[25] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestionModel obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.examTypeId)
      ..writeByte(2)
      ..write(obj.subjectId)
      ..writeByte(3)
      ..write(obj.topicId)
      ..writeByte(4)
      ..write(obj.year)
      ..writeByte(5)
      ..write(obj.questionType)
      ..writeByte(6)
      ..write(obj.body)
      ..writeByte(7)
      ..write(obj.bodyImageUrl)
      ..writeByte(8)
      ..write(obj.optionA)
      ..writeByte(9)
      ..write(obj.optionAImageUrl)
      ..writeByte(10)
      ..write(obj.optionB)
      ..writeByte(11)
      ..write(obj.optionBImageUrl)
      ..writeByte(12)
      ..write(obj.optionC)
      ..writeByte(13)
      ..write(obj.optionCImageUrl)
      ..writeByte(14)
      ..write(obj.optionD)
      ..writeByte(15)
      ..write(obj.optionDImageUrl)
      ..writeByte(16)
      ..write(obj.optionE)
      ..writeByte(17)
      ..write(obj.optionEImageUrl)
      ..writeByte(18)
      ..write(obj.correctOption)
      ..writeByte(19)
      ..write(obj.correctAnswerText)
      ..writeByte(20)
      ..write(obj.explanation)
      ..writeByte(21)
      ..write(obj.explanationImageUrl)
      ..writeByte(22)
      ..write(obj.specialType)
      ..writeByte(23)
      ..write(obj.passageGroupId)
      ..writeByte(24)
      ..write(obj.passageOrder)
      ..writeByte(25)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

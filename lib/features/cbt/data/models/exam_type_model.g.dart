// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_type_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExamTypeSubjectRefAdapter extends TypeAdapter<ExamTypeSubjectRef> {
  @override
  final typeId = 111;

  @override
  ExamTypeSubjectRef read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamTypeSubjectRef(
      id: (fields[0] as num).toInt(),
      name: fields[1] as String,
      slug: fields[2] as String,
      isEnglish: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ExamTypeSubjectRef obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.slug)
      ..writeByte(3)
      ..write(obj.isEnglish);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamTypeSubjectRefAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExamTypeModelAdapter extends TypeAdapter<ExamTypeModel> {
  @override
  final typeId = 11;

  @override
  ExamTypeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamTypeModel(
      id: (fields[0] as num).toInt(),
      name: fields[1] as String,
      slug: fields[2] as String,
      description: fields[3] as String?,
      imageUrl: fields[4] as String?,
      price: (fields[5] as num).toDouble(),
      maxScorePerSubject: fields[6] as num,
      hasAggregateMax: fields[7] as bool,
      aggregateMaxScore: fields[8] as num?,
      standardDurationMinutes: (fields[9] as num).toInt(),
      englishQuestionCount: (fields[10] as num).toInt(),
      otherSubjectQuestionCount: (fields[11] as num).toInt(),
      minSubjects: (fields[12] as num).toInt(),
      maxSubjects: (fields[13] as num).toInt(),
      englishCompulsory: fields[14] as bool,
      hasTheory: fields[15] as bool,
      hasPractical: fields[16] as bool,
      hasComprehension: fields[17] as bool,
      hasRegister: fields[18] as bool,
      hasLiterature: fields[19] as bool,
      showsPercentageAverage: fields[20] as bool,
      subjects: fields[21] == null
          ? const []
          : (fields[21] as List).cast<ExamTypeSubjectRef>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExamTypeModel obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.slug)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.price)
      ..writeByte(6)
      ..write(obj.maxScorePerSubject)
      ..writeByte(7)
      ..write(obj.hasAggregateMax)
      ..writeByte(8)
      ..write(obj.aggregateMaxScore)
      ..writeByte(9)
      ..write(obj.standardDurationMinutes)
      ..writeByte(10)
      ..write(obj.englishQuestionCount)
      ..writeByte(11)
      ..write(obj.otherSubjectQuestionCount)
      ..writeByte(12)
      ..write(obj.minSubjects)
      ..writeByte(13)
      ..write(obj.maxSubjects)
      ..writeByte(14)
      ..write(obj.englishCompulsory)
      ..writeByte(15)
      ..write(obj.hasTheory)
      ..writeByte(16)
      ..write(obj.hasPractical)
      ..writeByte(17)
      ..write(obj.hasComprehension)
      ..writeByte(18)
      ..write(obj.hasRegister)
      ..writeByte(19)
      ..write(obj.hasLiterature)
      ..writeByte(20)
      ..write(obj.showsPercentageAverage)
      ..writeByte(21)
      ..write(obj.subjects);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

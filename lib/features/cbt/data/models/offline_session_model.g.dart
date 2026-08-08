// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineSessionModelAdapter extends TypeAdapter<OfflineSessionModel> {
  @override
  final typeId = 16;

  @override
  OfflineSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineSessionModel(
      offlineUuid: fields[0] as String,
      serverId: (fields[1] as num?)?.toInt(),
      examTypeId: (fields[2] as num).toInt(),
      mode: fields[3] as String,
      subjectIds: fields[4] == null
          ? const []
          : (fields[4] as List).cast<int>(),
      topicIds: fields[5] == null ? const [] : (fields[5] as List).cast<int>(),
      year: (fields[6] as num?)?.toInt(),
      questionIds: fields[7] == null
          ? const []
          : (fields[7] as List).cast<int>(),
      answers: fields[8] == null
          ? const {}
          : (fields[8] as Map).cast<int, String>(),
      bookmarkedQuestionIds: fields[9] == null
          ? const []
          : (fields[9] as List).cast<int>(),
      durationMinutes: (fields[10] as num?)?.toInt(),
      startedAt: (fields[11] as num).toInt(),
      submittedAt: (fields[12] as num?)?.toInt(),
      remainingSeconds: (fields[13] as num?)?.toInt(),
      status: fields[14] as String,
      score: fields[15] as num?,
      totalMaxScore: fields[16] as num?,
      subjectScores: fields[17] == null
          ? const {}
          : (fields[17] as Map).cast<int, num>(),
      isSynced: fields[18] == null ? false : fields[18] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineSessionModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.offlineUuid)
      ..writeByte(1)
      ..write(obj.serverId)
      ..writeByte(2)
      ..write(obj.examTypeId)
      ..writeByte(3)
      ..write(obj.mode)
      ..writeByte(4)
      ..write(obj.subjectIds)
      ..writeByte(5)
      ..write(obj.topicIds)
      ..writeByte(6)
      ..write(obj.year)
      ..writeByte(7)
      ..write(obj.questionIds)
      ..writeByte(8)
      ..write(obj.answers)
      ..writeByte(9)
      ..write(obj.bookmarkedQuestionIds)
      ..writeByte(10)
      ..write(obj.durationMinutes)
      ..writeByte(11)
      ..write(obj.startedAt)
      ..writeByte(12)
      ..write(obj.submittedAt)
      ..writeByte(13)
      ..write(obj.remainingSeconds)
      ..writeByte(14)
      ..write(obj.status)
      ..writeByte(15)
      ..write(obj.score)
      ..writeByte(16)
      ..write(obj.totalMaxScore)
      ..writeByte(17)
      ..write(obj.subjectScores)
      ..writeByte(18)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

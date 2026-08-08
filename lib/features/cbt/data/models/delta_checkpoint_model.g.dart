// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delta_checkpoint_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeltaCheckpointModelAdapter extends TypeAdapter<DeltaCheckpointModel> {
  @override
  final typeId = 17;

  @override
  DeltaCheckpointModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeltaCheckpointModel(
      examTypeId: (fields[0] as num).toInt(),
      lastSyncedAt: (fields[1] as num).toInt(),
      totalQuestions: (fields[2] as num).toInt(),
      checksum: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DeltaCheckpointModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.examTypeId)
      ..writeByte(1)
      ..write(obj.lastSyncedAt)
      ..writeByte(2)
      ..write(obj.totalQuestions)
      ..writeByte(3)
      ..write(obj.checksum);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeltaCheckpointModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

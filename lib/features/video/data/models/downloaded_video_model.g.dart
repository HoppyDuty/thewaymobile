// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloaded_video_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadedVideoModelAdapter extends TypeAdapter<DownloadedVideoModel> {
  @override
  final typeId = 30;

  @override
  DownloadedVideoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadedVideoModel(
      lessonId: (fields[0] as num).toInt(),
      courseId: (fields[1] as num).toInt(),
      courseSlug: fields[2] as String,
      title: fields[3] as String,
      thumbnailUrl: fields[4] as String?,
      durationSeconds: (fields[5] as num).toInt(),
      quality: fields[6] as String,
      localFilePath: fields[7] as String,
      fileSizeBytes: (fields[8] as num).toInt(),
      downloadedAt: (fields[9] as num).toInt(),
      expiresAt: (fields[10] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, DownloadedVideoModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.lessonId)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.courseSlug)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.thumbnailUrl)
      ..writeByte(5)
      ..write(obj.durationSeconds)
      ..writeByte(6)
      ..write(obj.quality)
      ..writeByte(7)
      ..write(obj.localFilePath)
      ..writeByte(8)
      ..write(obj.fileSizeBytes)
      ..writeByte(9)
      ..write(obj.downloadedAt)
      ..writeByte(10)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadedVideoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

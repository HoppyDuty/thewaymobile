// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_book_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedBookModelAdapter extends TypeAdapter<SavedBookModel> {
  @override
  final typeId = 40;

  @override
  SavedBookModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedBookModel(
      bookId: (fields[0] as num).toInt(),
      slug: fields[1] as String,
      title: fields[2] as String,
      coverUrl: fields[3] as String?,
      authorName: fields[4] as String?,
      pageCount: (fields[5] as num).toInt(),
      localFilePath: fields[6] as String,
      fileSizeBytes: (fields[7] as num).toInt(),
      savedAt: (fields[8] as num).toInt(),
      expiresAt: (fields[9] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, SavedBookModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.bookId)
      ..writeByte(1)
      ..write(obj.slug)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.coverUrl)
      ..writeByte(4)
      ..write(obj.authorName)
      ..writeByte(5)
      ..write(obj.pageCount)
      ..writeByte(6)
      ..write(obj.localFilePath)
      ..writeByte(7)
      ..write(obj.fileSizeBytes)
      ..writeByte(8)
      ..write(obj.savedAt)
      ..writeByte(9)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedBookModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

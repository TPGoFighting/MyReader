// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novel_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NovelModelAdapter extends TypeAdapter<NovelModel> {
  @override
  final int typeId = 0;

  @override
  NovelModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NovelModel(
      id: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      cover: fields[3] as String,
      latestChapter: fields[4] as String,
      category: fields[5] as String,
      chapters: (fields[6] as List).cast<ChapterModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, NovelModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.cover)
      ..writeByte(4)
      ..write(obj.latestChapter)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.chapters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NovelModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChapterModelAdapter extends TypeAdapter<ChapterModel> {
  @override
  final int typeId = 1;

  @override
  ChapterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChapterModel(
      novelId: fields[0] as String,
      chapterId: fields[1] as String,
      chapterTitle: fields[2] as String,
      content: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChapterModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.novelId)
      ..writeByte(1)
      ..write(obj.chapterId)
      ..writeByte(2)
      ..write(obj.chapterTitle)
      ..writeByte(3)
      ..write(obj.content);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

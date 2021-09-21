// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_video.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueryVideoAdapter extends TypeAdapter<QueryVideo> {
  @override
  final int typeId = 1;

  @override
  QueryVideo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueryVideo(
      name: fields[0] as String,
      id: fields[1] as String,
      path: fields[2] as String,
      url: fields[7] as String,
      author: fields[3] as String,
      quality: fields[6] as String,
      duration: fields[4] as String,
      thumbnail: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QueryVideo obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.thumbnail)
      ..writeByte(6)
      ..write(obj.quality)
      ..writeByte(7)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueryVideoAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

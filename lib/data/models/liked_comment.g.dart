// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liked_comment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LikedCommentAdapter extends TypeAdapter<LikedComment> {
  @override
  final int typeId = 0;

  @override
  LikedComment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LikedComment(
      channelId: fields[0] as String,
      author: fields[1] as String,
      text: fields[2] as String,
      publishedTime: fields[4] as String,
      likeCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LikedComment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.channelId)
      ..writeByte(1)
      ..write(obj.author)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(4)
      ..write(obj.publishedTime)
      ..writeByte(5)
      ..write(obj.likeCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LikedCommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

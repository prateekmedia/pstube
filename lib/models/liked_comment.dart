import 'package:hive_flutter/hive_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'liked_comment.g.dart';

@HiveType(typeId: 0)
class LikedComment {
  LikedComment({
    required this.channelId,
    required this.author,
    required this.text,
    required this.publishedTime,
    required this.likeCount,
  });

  @HiveField(0)
  String channelId;

  @HiveField(1)
  String author;

  @HiveField(2)
  String text;

  @HiveField(4)
  String publishedTime;

  @HiveField(5)
  int likeCount;

  static LikedComment fromComment(Comment comment) {
    return LikedComment(
      channelId: comment.channelId.value,
      author: comment.author,
      text: comment.text,
      publishedTime: comment.publishedTime,
      likeCount: comment.likeCount,
    );
  }
}

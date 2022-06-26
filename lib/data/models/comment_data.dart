import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/liked_comment.dart';

class CommentData {
  CommentData({
    required this.commentorUrl,
    required this.author,
    required this.commentText,
    required this.commentedTime,
    required this.likeCount,
  });

  CommentData.fromLikedComment(LikedComment likedComment)
      : commentorUrl = likedComment.channelId,
        author = likedComment.author,
        commentText = likedComment.text,
        commentedTime = likedComment.publishedTime,
        likeCount = likedComment.likeCount,
        hearted = null;

  CommentData.fromComment(Comment comment)
      : commentorUrl = comment.commentorUrl ?? '',
        author = comment.author ?? '',
        commentText = comment.commentText ?? '',
        commentedTime = comment.commentedTime ?? '',
        likeCount = comment.likeCount ?? 0,
        hearted = comment.hearted;

  String commentorUrl;
  String author;
  String commentText;
  String commentedTime;
  int likeCount;
  bool? hearted;
}

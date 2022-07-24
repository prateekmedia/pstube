import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/liked_comment.dart';

class CommentData {
  CommentData({
    required this.commentorUrl,
    required this.author,
    required this.commentText,
    required this.commentedTime,
    required this.likeCount,
    required this.hearted,
    required this.isVerified,
    this.replies = 0,
  });

  CommentData.fromLikedComment(LikedComment likedComment)
      : commentorUrl = likedComment.channelId,
        isVerified = false,
        author = likedComment.author,
        commentText = likedComment.text,
        commentedTime = likedComment.publishedTime,
        likeCount = likedComment.likeCount,
        replies = 0,
        hearted = null;

  CommentData.fromComment(Comment comment)
      : commentorUrl = comment.commentorUrl ?? '',
        isVerified = comment.verified ?? false,
        author = comment.author ?? '',
        commentText = comment.commentText ?? '',
        commentedTime = comment.commentedTime ?? '',
        likeCount = comment.likeCount ?? 0,
        replies = comment.repliesPage != null ? 1 : 0,
        hearted = comment.hearted;

  final bool isVerified;
  final String commentorUrl;
  final String author;
  final String commentText;
  final String commentedTime;
  final int likeCount;
  final bool? hearted;
  final int replies;

  bool get hasReplies => replies > 0;
}

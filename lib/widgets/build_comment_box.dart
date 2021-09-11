import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutube/models/models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:flutube/widgets/widgets.dart';
import 'package:flutube/providers/providers.dart';

class BuildCommentBox extends HookConsumerWidget {
  final bool isInsideReply;
  final VoidCallback? onReplyTap;
  final Comment comment;

  const BuildCommentBox({
    Key? key,
    required this.comment,
    required this.onReplyTap,
    this.isInsideReply = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final likedList = ref.watch(likedListProvider);
    final isLiked = useState<bool>(false);

    updateLike() {
      isLiked.value = !isLiked.value;

      if (isLiked.value) {
        likedList.addComment(LikedComment.fromComment(comment));
      } else {
        likedList.removeComment(LikedComment.fromComment(comment));
      }
    }

    return CommentBox(
      comment: comment,
      onReplyTap: onReplyTap,
      isLiked: isLiked.value,
      isInsideReply: isInsideReply,
      updateLike: updateLike,
    );
  }
}

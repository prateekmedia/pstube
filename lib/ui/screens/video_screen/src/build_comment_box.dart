import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/comment_data.dart';

import 'package:pstube/data/models/models.dart';
import 'package:pstube/ui/states/states.dart';
import 'package:pstube/ui/widgets/widgets.dart';

class BuildCommentBox extends StatefulHookConsumerWidget {
  BuildCommentBox({
    super.key,
    required Comment comment,
    required this.onReplyTap,
    this.hideReplyBtn = false,
  })  : comment = CommentData.fromComment(comment),
        updateLike = null;

  BuildCommentBox.liked({
    super.key,
    required LikedComment comment,
    required this.onReplyTap,
    this.hideReplyBtn = false,
    this.updateLike,
  }) : comment = CommentData.fromLikedComment(comment);

  final bool hideReplyBtn;
  final VoidCallback? onReplyTap;
  final CommentData comment;
  final VoidCallback? updateLike;

  @override
  ConsumerState<BuildCommentBox> createState() => _BuildCommentBoxState();
}

class _BuildCommentBoxState extends ConsumerState<BuildCommentBox>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final likedList = ref.watch(likedListProvider);
    final isLiked = useState<bool>(widget.updateLike != null);

    void updateLike() {
      isLiked.value = !isLiked.value;

      if (isLiked.value) {
        likedList.addComment(LikedComment.fromComment(widget.comment));
      } else {
        likedList.removeComment(LikedComment.fromComment(widget.comment));
      }
    }

    return CommentBox(
      comment: widget.comment,
      onReplyTap: widget.onReplyTap,
      isLiked: isLiked.value,
      isInsideReply: widget.hideReplyBtn,
      updateLike: widget.updateLike ?? updateLike,
      isLikedComment: widget.updateLike != null,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

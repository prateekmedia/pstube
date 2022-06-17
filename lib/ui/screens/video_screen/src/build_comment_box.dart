import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:newpipeextractor_dart/models/comment.dart';

import 'package:pstube/data/models/models.dart';
import 'package:pstube/ui/states/states.dart';
import 'package:pstube/ui/widgets/widgets.dart';

class BuildCommentBox extends StatefulHookConsumerWidget {
  const BuildCommentBox({
    super.key,
    required this.comment,
    required this.onReplyTap,
    this.isInsideReply = false,
  });

  final bool isInsideReply;
  final VoidCallback? onReplyTap;
  final YoutubeComment comment;

  @override
  ConsumerState<BuildCommentBox> createState() => _BuildCommentBoxState();
}

class _BuildCommentBoxState extends ConsumerState<BuildCommentBox>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final likedList = ref.watch(likedListProvider);
    final isLiked = useState<bool>(false);

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
      isInsideReply: widget.isInsideReply,
      updateLike: updateLike,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

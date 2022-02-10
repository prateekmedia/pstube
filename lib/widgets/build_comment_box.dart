import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:sftube/models/models.dart';
import 'package:sftube/providers/providers.dart';
import 'package:sftube/widgets/widgets.dart';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class BuildCommentBox extends StatefulHookConsumerWidget {
  const BuildCommentBox({
    Key? key,
    required this.comment,
    required this.onReplyTap,
    this.isInsideReply = false,
  }) : super(key: key);

  final bool isInsideReply;
  final VoidCallback? onReplyTap;
  final Comment comment;

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

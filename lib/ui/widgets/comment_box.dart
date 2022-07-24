import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/comment_data.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/foundation/constants.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/screens/screens.dart';
import 'package:pstube/ui/widgets/widgets.dart';
import 'package:readmore/readmore.dart';

class CommentBox extends HookConsumerWidget {
  const CommentBox({
    super.key,
    required this.comment,
    required this.onReplyTap,
    this.isInsideReply = false,
    this.isLiked = false,
    this.isLikedComment = false,
    this.updateLike,
  });

  final bool isInsideReply;
  final VoidCallback? onReplyTap;
  final CommentData comment;
  final VoidCallback? updateLike;
  final bool isLiked;
  final bool isLikedComment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = PipedApi().getUnauthenticatedApi();
    final channelData = useFuture(
      useMemoized(
        () => api.channelInfoId(
          channelId: UploaderId(
            Constants.ytCom + comment.commentorUrl,
          ).value,
        ),
        [
          comment.commentorUrl,
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pushPage(
                  ChannelScreen(
                    channelId: comment.commentorUrl,
                  ),
                ),
                child: ChannelLogo(
                  channel: channelData.data?.data,
                  size: 35,
                  author: comment.author,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.pushPage(
                        ChannelScreen(
                          channelId: comment.commentorUrl,
                        ),
                      ),
                      child: Text(
                        comment.author,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconWithLabel(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      label: comment.commentedTime,
                      style:
                          context.textTheme.bodyText2!.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: ReadMoreText(
              comment.commentText,
              style: context.textTheme.bodyText2!
                  .copyWith(color: context.brightness.textColor),
              trimLines: 4,
              trimMode: TrimMode.Line,
              trimCollapsedText: '\n${context.locals.readMore}',
              trimExpandedText: '\n${context.locals.showLess}',
              lessStyle: context.textTheme.bodyText1!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              moreStyle: context.textTheme.bodyText1!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            children: [
              GestureDetector(
                onTap: updateLike?.call,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.getBackgroundColor.brighten(context, 20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (comment.likeCount).formatNumber,
                        style:
                            context.textTheme.bodyText2!.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLikedComment && !isInsideReply) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onReplyTap,
                  child: IconWithLabel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4)
                        .copyWith(left: 4),
                    label: context.locals.replies,
                    style: context.textTheme.bodyText2!.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

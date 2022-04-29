import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:pstube/models/models.dart';
import 'package:pstube/screens/screens.dart';
import 'package:pstube/utils/utils.dart';
import 'package:pstube/widgets/widgets.dart';

import 'package:readmore/readmore.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class CommentBox extends HookConsumerWidget {
  const CommentBox({
    Key? key,
    required this.comment,
    required this.onReplyTap,
    this.isInsideReply = false,
    this.isLiked = false,
    this.updateLike,
  }) : super(key: key);

  final bool isInsideReply;
  final VoidCallback? onReplyTap;
  final dynamic comment;
  final VoidCallback? updateLike;
  final bool isLiked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yt = YoutubeExplode();
    final channelData = useFuture(
      useMemoized(
        () => yt.channels.get(comment.channelUrl),
        [comment.channelUrl],
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context
                  .pushPage(ChannelScreen(id: comment.channelUrl.toString()));
            },
            child: ChannelLogo(channel: channelData, size: 40),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.pushPage(
                                  ChannelScreen(
                                    id: comment.channelUrl.value as String,
                                  ),
                                );
                              },
                              child: IconWithLabel(
                                label: comment.author as String,
                                margin: EdgeInsets.zero,
                                secColor: SecColor.dark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconWithLabel(
                        label: comment.publishedTime as String,
                        style:
                            context.textTheme.bodyText2!.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: !isInsideReply
                        ? ReadMoreText(
                            comment.text as String,
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
                          )
                        : SelectableText(comment.text as String),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: updateLike?.call,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: context.getBackgroundColor
                                .brighten(context, 20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                comment is LikedComment || isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (comment.likeCount as int).formatNumber,
                                style: context.textTheme.bodyText2!
                                    .copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (comment is Comment && comment.isHearted as bool) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: context.getBackgroundColor
                                .brighten(context, 20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red[600],
                            size: 22,
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      if (comment is Comment &&
                          !isInsideReply &&
                          comment.replyCount as int > 0)
                        GestureDetector(
                          onTap: onReplyTap,
                          child: IconWithLabel(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            label: '${comment.replyCount} '
                                '${comment.replyCount as int > 1 ? context.locals.replies.toLowerCase() : context.locals.reply}',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

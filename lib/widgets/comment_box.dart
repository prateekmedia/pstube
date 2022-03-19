import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:readmore/readmore.dart';

import 'package:sftube/models/models.dart';
import 'package:sftube/screens/screens.dart';
import 'package:sftube/utils/utils.dart';
import 'package:sftube/widgets/widgets.dart';

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
        () => yt.channels.get(comment.channelId),
        [comment.channelId],
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.pushPage(ChannelScreen(id: comment.channelId.toString()));
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
                                    id: comment.channelId.value as String,
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: updateLike?.call,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: kTabLabelPadding.left,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.thumbsUp,
                                size: 18,
                                color: comment is LikedComment || isLiked
                                    ? Colors.blue
                                    : null,
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
                      if (comment is Comment && comment.isHearted as bool)
                        Icon(
                          LucideIcons.heart,
                          color: Colors.red[600],
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (comment is Comment &&
                      !isInsideReply &&
                      comment.replyCount as int > 0)
                    InkWell(
                      onTap: onReplyTap,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: kTabLabelPadding.left,
                          vertical: 4,
                        ),
                        child: Text(
                          '${comment.replyCount} '
                          '${comment.replyCount as int > 1 ? context.locals.replies.toLowerCase() : context.locals.reply}',
                          style: TextStyle(
                            color: context.isDark
                                ? const Color.fromARGB(255, 40, 170, 255)
                                : const Color.fromARGB(255, 6, 95, 212),
                          ),
                        ),
                      ),
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

import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:readmore/readmore.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class BuildCommentBox extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () {
                context.pushPage(ChannelScreen(id: comment.channelId.value));
              },
              child: ChannelLogo(channelId: comment.channelId, size: 40)),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.pushPage(
                                    ChannelScreen(id: comment.channelId.value));
                              },
                              child: IconWithLabel(
                                label: comment.author,
                                margin: EdgeInsets.zero,
                                secColor: SecColor.dark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconWithLabel(
                        label: comment.publishedTime,
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
                            comment.text,
                            trimLines: 4,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: '\nRead more',
                            trimExpandedText: '\nShow less',
                            moreStyle: context.textTheme.bodyText1!.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : SelectableText(comment.text),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                            padding: kTabLabelPadding,
                            primary:
                                context.isDark ? Colors.white : Colors.black),
                        icon: const Icon(Icons.thumb_up, size: 18),
                        label: Text(
                          "${comment.likeCount.formatNumber}",
                          style: context.textTheme.bodyText2!
                              .copyWith(fontSize: 12),
                        ),
                      ),
                      if (comment.isHearted)
                        Icon(
                          Icons.favorite_rounded,
                          color: Colors.red[600],
                        ),
                    ],
                  ),
                  if (!isInsideReply)
                    TextButton(
                        style: TextButton.styleFrom(
                          primary: context.isDark
                              ? const Color.fromARGB(255, 40, 170, 255)
                              : const Color.fromARGB(255, 6, 95, 212),
                          padding: kTabLabelPadding,
                        ),
                        onPressed: comment.replyCount > 0 ? onReplyTap : null,
                        child: Text(
                            "${comment.replyCount} repl${comment.replyCount > 1 ? "ies" : "y"}"))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

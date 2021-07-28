import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:readmore/readmore.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Widget buildCommentBox(BuildContext context, Comment comment) => Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
              padding: EdgeInsets.symmetric(horizontal: 10),
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
                              child: iconWithLabel(
                                comment.author,
                                spacing: 0,
                                secColor: SecColor.dark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      iconWithLabel(
                        comment.publishedTime,
                        style:
                            context.textTheme.bodyText2!.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: ReadMoreText(
                      comment.text,
                      trimLines: 4,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: '\nRead more',
                      trimExpandedText: '\nShow less',
                      moreStyle:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.all(14),
                              primary:
                                  context.isDark ? Colors.white : Colors.black),
                          icon: Icon(
                            Icons.thumb_up,
                            size: 18,
                          ),
                          label: Text(
                            "${comment.likeCount.formatNumber}",
                            style: context.textTheme.bodyText2!
                                .copyWith(fontSize: 12),
                          ))
                    ],
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                          primary: context.isDark
                              ? Color.fromARGB(255, 40, 170, 255)
                              : Color.fromARGB(255, 6, 95, 212),
                          padding: EdgeInsets.symmetric(horizontal: 16)),
                      onPressed: comment.replyCount > 0 ? () {} : null,
                      child: Text(
                          "${comment.replyCount} repl${comment.replyCount > 1 ? "ies" : "y"}"))
                ],
              ),
            ),
          ),
        ],
      ),
    );

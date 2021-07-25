import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../utils/utils.dart';

class VideoScreen extends HookWidget {
  final Video video;
  const VideoScreen({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channel = useFuture(useMemoized(
        () => YoutubeExplode().channels.get(video.channelId.value)));
    final isLiked = useState<int>(0);
    final comments = useState<List?>(null);
    getComments() async {
      comments.value =
          (await YoutubeExplode().videos.commentsClient.getComments(video));
      YoutubeExplode().close();
    }

    getComments();

    return Scaffold(
      body: ListView(
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: CachedNetworkImageProvider(
                          video.thumbnails.mediumResUrl),
                    ),
                  ),
                ),
              ),
              Positioned(
                  child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: context.back,
                ),
              ))
            ],
          ),
          GestureDetector(
            onTap: () {
              showPopover(
                context,
                isScrollControlled: false,
                builder: (ctx) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description",
                        style: context.textTheme.bodyText2!.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(height: 15),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          video.description,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.headline6,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(video.engagement.viewCount.formatNumber + ' views'),
                      Text(video.publishDate != null
                          ? '  •  ' + timeago.format(video.publishDate!)
                          : ''),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                iconWithBottomLabel(
                  icon: isLiked.value == 1
                      ? Icons.thumb_up
                      : Icons.thumb_up_off_alt_outlined,
                  onPressed: () {
                    isLiked.value = isLiked.value != 1 ? 1 : 0;
                  },
                  label: video.engagement.likeCount != null
                      ? video.engagement.likeCount!.formatNumber
                      : "Like",
                ),
                iconWithBottomLabel(
                  icon: isLiked.value == 2
                      ? Icons.thumb_down
                      : Icons.thumb_down_off_alt_outlined,
                  onPressed: () {
                    isLiked.value = isLiked.value != 2 ? 2 : 0;
                  },
                  label: video.engagement.dislikeCount != null
                      ? video.engagement.dislikeCount!.formatNumber
                      : "Dislike",
                ),
                iconWithBottomLabel(
                  icon: Icons.share_outlined,
                  onPressed: () {
                    Share.share(video.url);
                  },
                  label: "Share",
                ),
                iconWithBottomLabel(
                  icon: Icons.download_outlined,
                  label: "Download",
                ),
                iconWithBottomLabel(
                  icon: Icons.playlist_add_outlined,
                  label: "Save",
                ),
              ],
            ),
          ),
          Divider(),
          ChannelInfo(
            channel: channel,
            isOnVideo: true,
          ),
          Divider(),
          ListTile(
            onTap: () => showPopover(
              context,
              isScrollControlled: false,
              builder: (ctx) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text("${(comments.value ?? []).length} comments",
                          style: context.textTheme.bodyText1!
                              .copyWith(fontWeight: FontWeight.w600)),
                    ),
                    for (Comment comment in comments.value ?? [])
                      buildCommentBox(comment),
                  ],
                );
              },
            ),
            title: Container(
              child: Text("Comments"),
            ),
            trailing: Text("${(comments.value ?? []).length}"),
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget buildCommentBox(Comment comment) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            ChannelLogo(channelId: comment.channelId),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    iconWithLabel(comment.author),
                    SizedBox(width: 10),
                    iconWithLabel(comment.publishedTime),
                  ],
                ),
                SizedBox(height: 10),
                Text(comment.text),
              ],
            ),
          ],
        ),
      );
}

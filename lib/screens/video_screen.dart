import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:ionicons/ionicons.dart';
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
    final replyComment = useState<Comment?>(null);
    final currentIndex = useState<int>(0);
    final PageController pageController = usePageController();
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
                  icon: const Icon(Icons.chevron_left),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description",
                        style: context.textTheme.bodyText2!.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          video.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
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
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  const SizedBox(height: 10),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
                  icon: Ionicons.share_social_outline,
                  onPressed: () {
                    Share.share(video.url);
                  },
                  label: "Share",
                ),
                iconWithBottomLabel(
                  icon: Ionicons.download_outline,
                  onPressed: () => showDownloadPopup(context, video),
                  label: "Download",
                ),
                iconWithBottomLabel(
                  icon: Icons.playlist_add_outlined,
                  label: "Save",
                ),
              ],
            ),
          ),
          const Divider(),
          ChannelInfo(
            channel: channel,
            isOnVideo: true,
          ),
          const Divider(),
          ListTile(
            onTap: () => showPopover(
              context,
              isScrollControlled: true,
              isScrollable: false,
              builder: (ctx) {
                return Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemBuilder: (_, index) => [
                      ListView(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: Text(
                                "${(comments.value ?? []).length} comments",
                                style: context.textTheme.bodyText1!
                                    .copyWith(fontWeight: FontWeight.w600)),
                          ),
                          for (Comment comment in comments.value ?? [])
                            buildCommentBox(context, comment, () {
                              replyComment.value = comment;
                              pageController.animateToPage(1,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInBack);
                            }),
                        ],
                      ),
                      showReplies(replyComment.value),
                    ][index],
                  ),
                );
              },
            ).whenComplete(() => currentIndex.value = 0),
            title: const Text("Comments"),
            trailing: Text("${(comments.value ?? []).length}"),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

Widget showReplies(Comment? comment) {
  return Text(comment != null ? comment.text : "");
}

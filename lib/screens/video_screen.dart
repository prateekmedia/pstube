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
  final bool loadData;
  const VideoScreen({Key? key, required this.video, this.loadData = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final yt = YoutubeExplode();
    final channel =
        useFuture(useMemoized(() => yt.channels.get(video.channelId.value)));
    final videoSnapshot =
        useFuture(useMemoized(() => yt.videos.get(video.id.value)));
    final Video videoData = loadData ? videoSnapshot.data ?? video : video;
    final isLiked = useState<int>(0);
    final replyComment = useState<Comment?>(null);
    final currentIndex = useState<int>(0);
    final commentSideWidget = useState<Widget?>(null);
    final currentItem = useState<int>(0);

    return Scaffold(
      body: FutureBuilder<CommentsList?>(
          future: (loadData && videoSnapshot.data == null)
              ? null
              : yt.videos.commentsClient
                  .getComments(videoData)
                  .whenComplete(() => yt.close()),
          builder: (context, commentsSnapshot) {
            return Flex(
              crossAxisAlignment: CrossAxisAlignment.start,
              direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 8,
                  child: ListView(
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
                                      videoData.thumbnails.mediumResUrl),
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
                        onTap: context.width < mobileWidth
                            ? () {
                                showPopover(
                                  context,
                                  isScrollControlled: false,
                                  builder: (ctx) =>
                                      DescriptionWidget(videoData: videoData),
                                );
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      videoData.title,
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
                                  Text(videoData
                                          .engagement.viewCount.formatNumber +
                                      ' views'),
                                  Text(videoData.publishDate != null
                                      ? '  •  ' +
                                          timeago.format(videoData.publishDate!)
                                      : ''),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
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
                              label: videoData.engagement.likeCount != null
                                  ? videoData.engagement.likeCount!.formatNumber
                                  : "Like",
                            ),
                            iconWithBottomLabel(
                              icon: isLiked.value == 2
                                  ? Icons.thumb_down
                                  : Icons.thumb_down_off_alt_outlined,
                              onPressed: () {
                                isLiked.value = isLiked.value != 2 ? 2 : 0;
                              },
                              label: videoData.engagement.dislikeCount != null
                                  ? videoData
                                      .engagement.dislikeCount!.formatNumber
                                  : "Dislike",
                            ),
                            iconWithBottomLabel(
                              icon: Ionicons.share_social_outline,
                              onPressed: () {
                                Share.share(videoData.url);
                              },
                              label: "Share",
                            ),
                            iconWithBottomLabel(
                              icon: Ionicons.download_outline,
                              onPressed: () =>
                                  showDownloadPopup(context, video),
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
                        onTap: commentsSnapshot.data == null
                            ? null
                            : currentItem.value == 1
                                ? () => currentItem.value = 0
                                : context.width < mobileWidth
                                    ? () => showPopover(
                                          context,
                                          isScrollable: false,
                                          builder: (ctx) {
                                            return Expanded(
                                              child: CommentsWidget(
                                                  snapshot: commentsSnapshot,
                                                  replyComment: replyComment),
                                            );
                                          },
                                        ).whenComplete(
                                            () => currentIndex.value = 0)
                                    : () {
                                        commentSideWidget.value =
                                            CommentsWidget(
                                          onClose: () => currentItem.value = 0,
                                          replyComment: replyComment,
                                          snapshot: commentsSnapshot,
                                        );
                                        currentItem.value = 1;
                                      },
                        title: const Text("Comments"),
                        trailing: Text(
                          (commentsSnapshot.data != null
                                  ? commentsSnapshot.data!.totalLength
                                  : 0)
                              .formatNumber,
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                if (context.width >= mobileWidth)
                  Flexible(
                    flex: 4,
                    child: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: DescriptionWidget(
                            videoData: videoData, isInsidePopup: false),
                      ),
                      if (commentSideWidget.value != null)
                        commentSideWidget.value!,
                    ][currentItem.value],
                  ),
              ],
            );
          }),
    );
  }
}

class CommentsWidget extends HookWidget {
  const CommentsWidget({
    Key? key,
    this.onClose,
    required this.replyComment,
    required this.snapshot,
  }) : super(key: key);

  final ValueNotifier<Comment?> replyComment;
  final AsyncSnapshot<CommentsList?> snapshot;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    final currentPage = useState<int>(0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: onClose != null ? 16 : 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (currentPage.value == 1)
                    ? IconButton(
                        onPressed: () {
                          pageController.animateToPage(0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut);
                          replyComment.value = null;
                        },
                        icon: const Icon(Icons.chevron_left),
                      )
                    : const SizedBox(),
                IconButton(
                  onPressed: onClose ?? context.back,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              onPageChanged: (index) => currentPage.value = index,
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (_, index) => [
                ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Text(
                          (snapshot.data != null
                                      ? snapshot.data!.totalLength
                                      : 0)
                                  .formatNumber +
                              " comments",
                          style: context.textTheme.bodyText1!
                              .copyWith(fontWeight: FontWeight.w600)),
                    ),
                    for (Comment comment in snapshot.data ?? [])
                      buildCommentBox(context, comment, () {
                        replyComment.value = comment;
                        pageController.animateToPage(1,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut);
                      }),
                  ],
                ),
                WillPopScope(
                    child: showReplies(context, replyComment.value),
                    onWillPop: () async {
                      await pageController.animateToPage(0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut);
                      replyComment.value = null;
                      return false;
                    }),
              ][index],
            ),
          ),
        ],
      ),
    );
  }
}

class DescriptionWidget extends StatelessWidget {
  final bool isInsidePopup;

  const DescriptionWidget({
    Key? key,
    required this.videoData,
    this.isInsidePopup = true,
  }) : super(key: key);

  final Video videoData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: context.textTheme.bodyText2!.copyWith(
                fontWeight: FontWeight.bold, fontSize: isInsidePopup ? 15 : 18),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SelectableText(
              videoData.description,
              style: TextStyle(fontSize: isInsidePopup ? 16 : 17),
            ),
          ),
        ],
      ),
    );
  }
}

Widget showReplies(BuildContext context, Comment? comment) {
  final yt = YoutubeExplode();
  getReplies() async {
    if (comment == null) return null;
    var replies = await yt.videos.commentsClient.getReplies(comment);
    yt.close();
    return replies;
  }

  return comment != null
      ? ListView(
          children: [
            buildCommentBox(context, comment, null, isInsideReply: true),
            FutureBuilder<List?>(
                future: getReplies(),
                builder: (context, snapshot) {
                  return snapshot.data != null
                      ? Container(
                          padding: const EdgeInsets.only(left: 50),
                          child: Column(
                            children: [
                              for (Comment reply in snapshot.data!)
                                buildCommentBox(context, reply, null,
                                    isInsideReply: true)
                            ],
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        );
                }),
          ],
        )
      : const Center(
          child: CircularProgressIndicator(),
        );
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutube/providers/providers.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../utils/utils.dart';

class VideoScreen extends HookConsumerWidget {
  final Video? video;
  final String? videoId;
  final bool loadData;
  const VideoScreen({
    Key? key,
    required this.video,
    this.videoId,
    this.loadData = false,
  })  : assert(videoId != null || video != null),
        super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final yt = YoutubeExplode();
    final videoSnapshot = loadData || videoId != null
        ? useFuture(useMemoized(() => yt.videos.get(videoId ?? video!.id.value).whenComplete(() => yt.close())))
        : null;
    final Video? videoData = videoSnapshot != null ? videoSnapshot.data : video;
    final replyComment = useState<Comment?>(null);
    final currentIndex = useState<int>(0);
    final commentSideWidget = useState<Widget?>(null);
    final downloadsSideWidget = useState<Widget?>(null);
    final _textController = TextEditingController();

    final likedList = ref.watch(likedListProvider);
    final isLiked = videoData != null ? useState<int>(likedList.likedVideoList.contains(videoData.url) ? 1 : 0) : null;

    updateLike(int value) {
      isLiked!.value = isLiked.value != value ? value : 0;

      if (isLiked.value == 1) {
        likedList.addVideo(videoData!.url);
      } else {
        likedList.removeVideo(videoData!.url);
      }
    }

    return SafeArea(
      child: Scaffold(
        appBar: video == null && videoSnapshot == null || videoData == null
            ? AppBar(
                leading: IconButton(
                    onPressed: context.back,
                    icon: const Icon(
                      Icons.chevron_left,
                    )))
            : null,
        body: video == null && videoSnapshot == null
            ? const Center(child: Text('Video not found!'))
            : videoData == null
                ? getCircularProgressIndicator()
                : FutureBuilder<CommentsList?>(
                    future: yt.videos.commentsClient.getComments(videoData).whenComplete(() => yt.close()),
                    builder: (context, commentsSnapshot) {
                      return Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        direction: Axis.horizontal,
                        children: [
                          Flexible(
                            flex: 8,
                            child: FtBody(
                              child: ListView(
                                children: [
                                  Stack(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: CachedNetworkImage(
                                          imageUrl: videoData.thumbnails.mediumResUrl,
                                          fit: BoxFit.fill,
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
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          videoData.title,
                                          style: context.textTheme.headline6,
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(videoData.engagement.viewCount.formatNumber + ' views'),
                                            Text(videoData.publishDate != null
                                                ? '  •  ' + timeago.format(videoData.publishDate!)
                                                : ''),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        iconWithBottomLabel(
                                          icon: isLiked!.value == 1 ? Icons.thumb_up : Icons.thumb_up_off_alt_outlined,
                                          onPressed: () => updateLike(1),
                                          label: videoData.engagement.likeCount != null
                                              ? videoData.engagement.likeCount!.formatNumber
                                              : "Like",
                                        ),
                                        iconWithBottomLabel(
                                          icon:
                                              isLiked.value == 2 ? Icons.thumb_down : Icons.thumb_down_off_alt_outlined,
                                          onPressed: () => updateLike(2),
                                          label: videoData.engagement.dislikeCount != null
                                              ? videoData.engagement.dislikeCount!.formatNumber
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
                                          onPressed: downloadsSideWidget.value != null
                                              ? () => downloadsSideWidget.value = null
                                              : context.isMobile
                                                  ? () => showDownloadPopup(context, videoData)
                                                  : () {
                                                      commentSideWidget.value = null;
                                                      downloadsSideWidget.value = Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const SizedBox(width: 15),
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: 4,
                                                                    vertical: 16,
                                                                  ),
                                                                  child: Text(
                                                                    'Download links',
                                                                    style: context.textTheme.bodyText2!.copyWith(
                                                                        fontWeight: FontWeight.bold, fontSize: 18),
                                                                  ),
                                                                ),
                                                              ),
                                                              IconButton(
                                                                  icon: const Icon(Icons.close),
                                                                  onPressed: () {
                                                                    downloadsSideWidget.value = null;
                                                                  }),
                                                              const SizedBox(width: 16),
                                                            ],
                                                          ),
                                                          Expanded(
                                                            child: SingleChildScrollView(
                                                              padding: const EdgeInsets.symmetric(
                                                                  horizontal: 15, vertical: 12),
                                                              child: DownloadsWidget(
                                                                video: videoData,
                                                                onClose: () => downloadsSideWidget.value = null,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                          label: "Download",
                                        ),
                                        iconWithBottomLabel(
                                          icon: Icons.playlist_add_outlined,
                                          onPressed: () {
                                            showPopoverWB(
                                              context: context,
                                              cancelText: "DONE",
                                              confirmText: "CREATE",
                                              controller: _textController,
                                              hint: "Create New",
                                              onConfirm: () {
                                                ref
                                                    .read(playlistProvider.notifier)
                                                    .addPlaylist(_textController.value.text);
                                                _textController.value = const TextEditingValue();
                                              },
                                              builder: (ctx) => PlaylistPopup(videoData: videoData),
                                            );
                                          },
                                          label: "Save",
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),
                                  ChannelInfo(
                                    channel: null,
                                    channelId: videoData.channelId.value,
                                    isOnVideo: true,
                                  ),
                                  const Divider(),
                                  ListTile(
                                    onTap: commentsSnapshot.data == null
                                        ? null
                                        : commentSideWidget.value != null
                                            ? () => commentSideWidget.value = null
                                            : context.isMobile
                                                ? () => showPopover(
                                                      context: context,
                                                      isScrollable: false,
                                                      innerPadding: EdgeInsets.zero,
                                                      builder: (ctx) {
                                                        return CommentsWidget(
                                                          snapshot: commentsSnapshot,
                                                          replyComment: replyComment,
                                                        );
                                                      },
                                                    ).whenComplete(() => currentIndex.value = 0)
                                                : () {
                                                    downloadsSideWidget.value = null;
                                                    commentSideWidget.value = CommentsWidget(
                                                      onClose: () => commentSideWidget.value = null,
                                                      replyComment: replyComment,
                                                      snapshot: commentsSnapshot,
                                                    );
                                                  },
                                    title: const Text("Comments"),
                                    trailing: Text(
                                      (commentsSnapshot.data != null ? commentsSnapshot.data!.totalLength : 0)
                                          .formatNumber,
                                    ),
                                  ),
                                  const Divider(),
                                  if (context.isMobile) DescriptionWidget(video: videoData),
                                ],
                              ),
                            ),
                          ),
                          if (!context.isMobile)
                            Flexible(
                              flex: 4,
                              child: [
                                DescriptionWidget(video: videoData, isInsidePopup: false),
                                if (commentSideWidget.value != null) commentSideWidget.value!,
                                if (downloadsSideWidget.value != null) downloadsSideWidget.value!,
                              ].last,
                            ),
                        ],
                      );
                    }),
      ),
    );
  }
}

class PlaylistPopup extends ConsumerWidget {
  const PlaylistPopup({
    Key? key,
    required this.videoData,
  }) : super(key: key);

  final Video videoData;

  @override
  Widget build(context, ref) {
    final playlist = ref.watch(playlistProvider);
    final playlistP = ref.read(playlistProvider.notifier);
    return Column(children: [
      Text('Save to...', style: context.textTheme.headline6!.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
      const Divider(),
      for (var entry in playlist.entries)
        CheckboxListTile(
          value: entry.value.contains(videoData.url),
          onChanged: (value) {
            if (value!) {
              playlistP.addVideo(entry.key, videoData.url);
            } else {
              playlistP.removeVideo(entry.key, videoData.url);
            }
          },
          title: Text(entry.key),
        )
    ]);
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
    return Column(
      children: [
        AppBar(
          backgroundColor: context.getAltBackgroundColor,
          leading: (currentPage.value == 1)
              ? IconButton(
                  onPressed: () {
                    pageController.animateToPage(0,
                        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
                    replyComment.value = null;
                  },
                  icon: Icon(Icons.chevron_left, color: context.textTheme.bodyText1!.color),
                )
              : const SizedBox(),
          centerTitle: true,
          title: Text(
              (currentPage.value == 0)
                  ? (snapshot.data != null ? snapshot.data!.totalLength : 0).formatNumber + " comments"
                  : "Replies",
              style: context.textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
          actions: [
            IconButton(
              onPressed: onClose ?? context.back,
              icon: Icon(Icons.close, color: context.textTheme.bodyText1!.color),
            )
          ],
        ),
        Expanded(
          child: PageView.builder(
            onPageChanged: (index) => currentPage.value = index,
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (_, index) => [
              ListView(
                controller: ScrollController(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (Comment comment in snapshot.data ?? [])
                    BuildCommentBox(
                      comment: comment,
                      onReplyTap: () {
                        replyComment.value = comment;
                        pageController.animateToPage(1,
                            duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
                      },
                    )
                ],
              ),
              WillPopScope(
                  child: showReplies(
                    context,
                    replyComment.value,
                    EdgeInsets.symmetric(horizontal: onClose != null ? 16 : 0),
                  ),
                  onWillPop: () async {
                    await pageController.animateToPage(0,
                        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
                    replyComment.value = null;
                    return false;
                  }),
            ][index],
          ),
        ),
      ],
    );
  }
}

Widget showReplies(BuildContext context, Comment? comment, EdgeInsets padding) {
  final yt = YoutubeExplode();
  getReplies() async {
    if (comment == null) return null;
    var replies = await yt.videos.commentsClient.getReplies(comment);
    yt.close();
    return replies;
  }

  return comment != null
      ? ListView(
          controller: ScrollController(),
          padding: padding,
          children: [
            BuildCommentBox(
              comment: comment,
              onReplyTap: null,
              isInsideReply: true,
            ),
            FutureBuilder<List?>(
                future: getReplies(),
                builder: (context, snapshot) {
                  return snapshot.data != null
                      ? Container(
                          padding: const EdgeInsets.only(left: 50),
                          child: Column(
                            children: [
                              for (Comment reply in snapshot.data!)
                                BuildCommentBox(
                                  comment: reply,
                                  onReplyTap: null,
                                  isInsideReply: true,
                                ),
                            ],
                          ),
                        )
                      : getCircularProgressIndicator();
                }),
          ],
        )
      : getCircularProgressIndicator();
}

class DescriptionWidget extends StatelessWidget {
  final bool isInsidePopup;

  const DescriptionWidget({
    Key? key,
    required this.video,
    this.isInsidePopup = true,
  }) : super(key: key);

  final Video video;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      controller: ScrollController(),
      padding: const EdgeInsets.all(15),
      children: [
        Text(
          "Description",
          style: context.textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold, fontSize: isInsidePopup ? 15 : 18),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DescriptionInfoWidget(
              title: (((video.engagement.likeCount ?? 0) /
                              ((video.engagement.likeCount ?? 0) + (video.engagement.dislikeCount ?? 0))) *
                          100)
                      .toStringAsFixed(0) +
                  '%',
              body: 'Like ratio',
            ),
            DescriptionInfoWidget(
              title: video.engagement.viewCount.addCommas,
              body: 'views',
            ),
            DescriptionInfoWidget(
              title: DateFormat('dd MMM yyy').format(video.publishDate ?? DateTime.now()),
              body: 'Upload date',
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: CustomText(
            video.description,
            onTap: (Type type, link) => link.launchIt(),
            definitions: const [
              TextDefinition(matcher: UrlMatcher()),
              TextDefinition(matcher: EmailMatcher()),
            ],
            matchStyle: const TextStyle(color: Colors.lightBlue),
            // `tapStyle` is not used if both `onTap` and `onLongPress`
            // are null or not set.
            tapStyle: const TextStyle(color: Colors.yellow),
            style: TextStyle(fontSize: isInsidePopup ? 16 : 17),
          ),
        ),
      ],
    );
  }
}

class DescriptionInfoWidget extends StatelessWidget {
  const DescriptionInfoWidget({
    Key? key,
    required this.title,
    required this.body,
  }) : super(key: key);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: context.textTheme.headline6!),
        Text(body),
      ],
    );
  }
}

import 'package:ant_icons/ant_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:custom_text/custom_text.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutube/providers/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:flutube/utils/utils.dart';

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
        ? useFuture(useMemoized(() => yt.videos
            .get(videoId ?? video!.id.value)
            .whenComplete(() => yt.close())))
        : null;
    final Video? videoData = videoSnapshot != null ? videoSnapshot.data : video;
    final replyComment = useState<Comment?>(null);
    final currentIndex = useState<int>(0);
    final commentSideWidget = useState<Widget?>(null);
    final downloadsSideWidget = useState<Widget?>(null);
    final _textController = TextEditingController();

    final likedList = ref.watch(likedListProvider);
    final isLiked = videoData != null
        ? useState<int>(
            likedList.likedVideoList.contains(videoData.url) ? 1 : 0)
        : null;

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
                    future: yt.videos.commentsClient.getComments(videoData),
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
                                          imageUrl:
                                              videoData.thumbnails.mediumResUrl,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          videoData.title,
                                          style: context.textTheme.headline3,
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(videoData.engagement.viewCount
                                                    .formatNumber +
                                                ' views'),
                                            Text(videoData.publishDate != null
                                                ? '  •  ' +
                                                    timeago.format(
                                                        videoData.publishDate!)
                                                : ''),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        iconWithBottomLabel(
                                          icon: isLiked!.value == 1
                                              ? AntIcons.like
                                              : AntIcons.like_outline,
                                          onPressed: () => updateLike(1),
                                          label:
                                              videoData.engagement.likeCount !=
                                                      null
                                                  ? videoData.engagement
                                                      .likeCount!.formatNumber
                                                  : context.locals.like,
                                        ),
                                        iconWithBottomLabel(
                                          icon: isLiked.value == 2
                                              ? AntIcons.dislike
                                              : AntIcons.dislike_outline,
                                          onPressed: () => updateLike(2),
                                          label: context.locals.dislike,
                                        ),
                                        iconWithBottomLabel(
                                          icon: AntIcons.share_alt,
                                          onPressed: () {
                                            Share.share(videoData.url);
                                          },
                                          label: context.locals.share,
                                        ),
                                        iconWithBottomLabel(
                                          icon: Icons.download,
                                          onPressed: downloadsSideWidget
                                                      .value !=
                                                  null
                                              ? () => downloadsSideWidget
                                                  .value = null
                                              : context.isMobile
                                                  ? () => showDownloadPopup(
                                                      context,
                                                      video: videoData)
                                                  : () {
                                                      commentSideWidget.value =
                                                          null;
                                                      downloadsSideWidget
                                                          .value = Column(
                                                        children: [
                                                          AppBar(
                                                            leading:
                                                                const SizedBox(),
                                                            centerTitle: true,
                                                            title: Text(context
                                                                .locals
                                                                .downloadLinks),
                                                            actions: [
                                                              IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .close),
                                                                  onPressed:
                                                                      () {
                                                                    downloadsSideWidget
                                                                            .value =
                                                                        null;
                                                                  }),
                                                              const SizedBox(
                                                                  width: 16),
                                                            ],
                                                          ),
                                                          Expanded(
                                                            child:
                                                                SingleChildScrollView(
                                                              controller:
                                                                  ScrollController(),
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 12),
                                                              child:
                                                                  DownloadsWidget(
                                                                video:
                                                                    videoData,
                                                                onClose: () =>
                                                                    downloadsSideWidget
                                                                            .value =
                                                                        null,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                          label: context.locals.download,
                                        ),
                                        iconWithBottomLabel(
                                          icon: AntIcons.unordered_list,
                                          onPressed: () {
                                            showPopoverWB(
                                              context: context,
                                              cancelText: context.locals.done,
                                              confirmText:
                                                  context.locals.create,
                                              controller: _textController,
                                              title: context.locals.save,
                                              hint: context.locals.createNew,
                                              onConfirm: () {
                                                ref
                                                    .read(playlistProvider
                                                        .notifier)
                                                    .addPlaylist(_textController
                                                        .value.text);
                                                _textController.value =
                                                    const TextEditingValue();
                                              },
                                              builder: (ctx) => PlaylistPopup(
                                                  videoData: videoData),
                                            );
                                          },
                                          label: context.locals.save,
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
                                            ? () =>
                                                commentSideWidget.value = null
                                            : context.isMobile
                                                ? () => showPopover(
                                                      context: context,
                                                      isScrollable: false,
                                                      innerPadding:
                                                          EdgeInsets.zero,
                                                      builder: (ctx) {
                                                        return CommentsWidget(
                                                          snapshot:
                                                              commentsSnapshot,
                                                          replyComment:
                                                              replyComment,
                                                        );
                                                      },
                                                    ).whenComplete(() =>
                                                        currentIndex.value = 0)
                                                : () {
                                                    downloadsSideWidget.value =
                                                        null;
                                                    commentSideWidget.value =
                                                        CommentsWidget(
                                                      onClose: () =>
                                                          commentSideWidget
                                                              .value = null,
                                                      replyComment:
                                                          replyComment,
                                                      snapshot:
                                                          commentsSnapshot,
                                                    );
                                                  },
                                    title: Text(context.locals.comments),
                                    trailing: Text(
                                      (commentsSnapshot.data != null
                                              ? commentsSnapshot
                                                  .data!.totalLength
                                              : 0)
                                          .formatNumber,
                                    ),
                                  ),
                                  const Divider(),
                                  if (context.isMobile)
                                    DescriptionWidget(video: videoData),
                                ],
                              ),
                            ),
                          ),
                          if (!context.isMobile)
                            Flexible(
                              flex: 4,
                              child: [
                                DescriptionWidget(
                                    video: videoData, isInsidePopup: false),
                                if (commentSideWidget.value != null)
                                  commentSideWidget.value!,
                                if (downloadsSideWidget.value != null)
                                  downloadsSideWidget.value!,
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
    var isMounted = useIsMounted();
    final PageController pageController = PageController();
    final _currentPage = useState<CommentsList?>(snapshot.data);
    final controller = useScrollController();
    final currentPage = useState<int>(0);

    void _getMoreData() async {
      if (isMounted() &&
          controller.position.pixels == controller.position.maxScrollExtent &&
          _currentPage.value != null) {
        final page = await (_currentPage.value)!.nextPage();
        if (page == null || page.isEmpty && !isMounted()) return;

        _currentPage.value = page;
      }
    }

    useEffect(() {
      controller.addListener(_getMoreData);
      return () => controller.removeListener(_getMoreData);
    }, [controller]);

    return Column(
      children: [
        AppBar(
          leading: (currentPage.value == 1)
              ? IconButton(
                  onPressed: () {
                    pageController.animateToPage(0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut);
                    replyComment.value = null;
                  },
                  icon: Icon(Icons.chevron_left,
                      color: context.textTheme.bodyText1!.color),
                )
              : const SizedBox(),
          centerTitle: true,
          title: Text((currentPage.value == 0)
              ? (snapshot.data != null ? snapshot.data!.totalLength : 0)
                      .formatNumber +
                  " " +
                  context.locals.comments.toLowerCase()
              : context.locals.replies),
          actions: [
            IconButton(
              onPressed: onClose ?? context.back,
              icon:
                  Icon(Icons.close, color: context.textTheme.bodyText1!.color),
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
              ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _currentPage.value!.length + 1,
                itemBuilder: (ctx, idx) {
                  final comment = idx != _currentPage.value!.length
                      ? _currentPage.value![idx]
                      : null;
                  return idx == _currentPage.value!.length
                      ? getCircularProgressIndicator()
                      : BuildCommentBox(
                          comment: comment!,
                          onReplyTap: () {
                            replyComment.value = comment;
                            pageController.animateToPage(1,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut);
                          },
                        );
                },
              ),
              WillPopScope(
                  child: showReplies(
                    context,
                    replyComment.value,
                    EdgeInsets.symmetric(horizontal: onClose != null ? 16 : 0),
                  ),
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
          context.locals.description,
          style: context.textTheme.bodyText1!.copyWith(
              fontWeight: FontWeight.bold, fontSize: isInsidePopup ? 16 : 18),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DescriptionInfoWidget(
              title: video.engagement.viewCount.addCommas,
              body: context.locals.views,
            ),
            DescriptionInfoWidget(
              title: DateFormat('dd MMM yyy')
                  .format(video.publishDate ?? DateTime.now()),
              body: context.locals.uploadDate,
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
        Text(title, style: context.textTheme.headline3!),
        Text(body),
      ],
    );
  }
}

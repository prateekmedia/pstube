import 'package:ant_icons/ant_icons.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';

import 'package:sftube/providers/providers.dart';
import 'package:sftube/utils/utils.dart';
import 'package:sftube/widgets/video_player.dart';
import 'package:sftube/widgets/widgets.dart';

import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoScreen extends StatefulHookConsumerWidget {
  const VideoScreen({
    Key? key,
    required this.video,
    this.videoId,
    this.loadData = false,
  })  : assert(
          videoId != null || video != null,
          "VideoId and video both can't be null",
        ),
        super(key: key);

  final Video? video;
  final String? videoId;
  final bool loadData;

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final yt = YoutubeExplode();
    final videoSnapshot = widget.loadData || widget.videoId != null
        ? useFuture(
            useMemoized(
              () => yt.videos
                  .get(widget.videoId ?? widget.video!.id.value)
                  .whenComplete(yt.close),
            ),
          )
        : null;
    final videoData = videoSnapshot != null && videoSnapshot.hasData
        ? videoSnapshot.data
        : widget.video;
    final replyComment = useState<Comment?>(null);
    final commentSideWidget = useState<Widget?>(null);
    final downloadsSideWidget = useState<Widget?>(null);
    final _textController = TextEditingController();

    final likedList = ref.watch(likedListProvider);
    final isLiked = videoData != null
        ? useState<bool>(likedList.likedVideoList.contains(videoData.url))
        : null;

    void updateLike() {
      isLiked!.value = !isLiked.value;

      if (isLiked.value) {
        likedList.addVideo(videoData!.url);
      } else {
        likedList.removeVideo(videoData!.url);
      }
    }

    return SafeArea(
      child: Stack(
        children: [
          Stack(
            children: [
              Scaffold(
                body: widget.video == null && videoSnapshot == null
                    ? Center(child: Text(context.locals.videoNotFound))
                    : videoData == null
                        ? getCircularProgressIndicator()
                        : FutureBuilder<CommentsList?>(
                            future:
                                yt.videos.commentsClient.getComments(videoData),
                            builder: (context, commentsSnapshot) {
                              return FutureBuilder<StreamManifest>(
                                future: YoutubeExplode()
                                    .videos
                                    .streamsClient
                                    .getManifest(videoData.id),
                                builder: (context, snapshot) {
                                  return Flex(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    direction: Axis.horizontal,
                                    children: [
                                      Flexible(
                                        flex: 8,
                                        child: SFBody(
                                          child: Column(
                                            children: [
                                              if (videoPlatforms &&
                                                  snapshot.hasData &&
                                                  snapshot.data != null)
                                                VideoPlayer(
                                                  url: snapshot.data!.muxed
                                                      .firstWhere(
                                                        (element) => element
                                                            .qualityLabel
                                                            .contains(
                                                          '360',
                                                        ),
                                                      )
                                                      .url
                                                      .toString(),
                                                  resolutions: snapshot
                                                      .data!.muxed
                                                      .asMap()
                                                      .map(
                                                        (key, value) =>
                                                            MapEntry(
                                                          value.qualityLabel,
                                                          value.url.toString(),
                                                        ),
                                                      ),
                                                )
                                              else
                                                Stack(
                                                  children: [
                                                    AspectRatio(
                                                      aspectRatio: 16 / 9,
                                                      child: CachedNetworkImage(
                                                        imageUrl: videoData
                                                            .thumbnails
                                                            .mediumResUrl,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                    if (videoPlatforms) ...[
                                                      Container(
                                                        color: Colors.black
                                                            .withOpacity(0.25),
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: const [
                                                          Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                        ],
                                                      ),
                                                    ]
                                                  ],
                                                ),
                                              Flexible(
                                                child: Stack(
                                                  children: [
                                                    ListView(
                                                      shrinkWrap: true,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(
                                                            12,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                videoData.title,
                                                                style: context
                                                                    .textTheme
                                                                    .headline3,
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    '${videoData.engagement.viewCount.formatNumber}'
                                                                    ' views',
                                                                  ),
                                                                  Text(
                                                                    videoData.publishDate !=
                                                                            null
                                                                        ? '  •  ${timeago.format(
                                                                            videoData.publishDate!,
                                                                          )}'
                                                                        : '',
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 10,
                                                            vertical: 2,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              iconWithBottomLabel(
                                                                icon: isLiked!
                                                                        .value
                                                                    ? AntIcons
                                                                        .like
                                                                    : AntIcons
                                                                        .like_outline,
                                                                onPressed:
                                                                    updateLike,
                                                                label: videoData
                                                                            .engagement.likeCount !=
                                                                        null
                                                                    ? videoData
                                                                        .engagement
                                                                        .likeCount!
                                                                        .formatNumber
                                                                    : context
                                                                        .locals
                                                                        .like,
                                                              ),
                                                              iconWithBottomLabel(
                                                                icon: AntIcons
                                                                    .share_alt,
                                                                onPressed: () {
                                                                  Share.share(
                                                                    videoData
                                                                        .url,
                                                                  );
                                                                },
                                                                label: context
                                                                    .locals
                                                                    .share,
                                                              ),
                                                              iconWithBottomLabel(
                                                                icon: Icons
                                                                    .download,
                                                                onPressed: downloadsSideWidget
                                                                            .value !=
                                                                        null
                                                                    ? () =>
                                                                        downloadsSideWidget.value =
                                                                            null
                                                                    : () {
                                                                        commentSideWidget.value =
                                                                            null;
                                                                        downloadsSideWidget.value =
                                                                            ShowDownloadsWidget(
                                                                          manifest:
                                                                              snapshot.data,
                                                                          downloadsSideWidget:
                                                                              downloadsSideWidget,
                                                                          videoData:
                                                                              videoData,
                                                                        );
                                                                      },
                                                                label: context
                                                                    .locals
                                                                    .download,
                                                              ),
                                                              iconWithBottomLabel(
                                                                icon: AntIcons
                                                                    .copy_outline,
                                                                onPressed: () {
                                                                  Clipboard
                                                                      .setData(
                                                                    ClipboardData(
                                                                      text: videoData
                                                                          .url,
                                                                    ),
                                                                  );
                                                                  BotToast
                                                                      .showText(
                                                                    text: context
                                                                        .locals
                                                                        .copiedToClipboard,
                                                                  );
                                                                },
                                                                label: context
                                                                    .locals
                                                                    .copyLink,
                                                              ),
                                                              iconWithBottomLabel(
                                                                icon: AntIcons
                                                                    .unordered_list,
                                                                onPressed: () {
                                                                  showPopoverWB<
                                                                      dynamic>(
                                                                    context:
                                                                        context,
                                                                    cancelText:
                                                                        context
                                                                            .locals
                                                                            .done,
                                                                    hideConfirm:
                                                                        true,
                                                                    controller:
                                                                        _textController,
                                                                    title: context
                                                                        .locals
                                                                        .save,
                                                                    hint: context
                                                                        .locals
                                                                        .createNew,
                                                                    onConfirm:
                                                                        () {
                                                                      ref
                                                                          .read(
                                                                            playlistProvider.notifier,
                                                                          )
                                                                          .addPlaylist(
                                                                            _textController.value.text,
                                                                          );
                                                                      _textController
                                                                              .value =
                                                                          TextEditingValue
                                                                              .empty;
                                                                    },
                                                                    builder:
                                                                        (ctx) =>
                                                                            PlaylistPopup(
                                                                      videoData:
                                                                          videoData,
                                                                    ),
                                                                  );
                                                                },
                                                                label: context
                                                                    .locals
                                                                    .save,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const Divider(),
                                                        ChannelInfo(
                                                          channel: null,
                                                          channelId: videoData
                                                              .channelId.value,
                                                          isOnVideo: true,
                                                        ),
                                                        const Divider(
                                                          height: 4,
                                                        ),
                                                        ListTile(
                                                          onTap: commentsSnapshot
                                                                      .data ==
                                                                  null
                                                              ? null
                                                              : commentSideWidget
                                                                          .value !=
                                                                      null
                                                                  ? () => commentSideWidget
                                                                          .value =
                                                                      null
                                                                  : () {
                                                                      downloadsSideWidget
                                                                              .value =
                                                                          null;
                                                                      commentSideWidget
                                                                              .value =
                                                                          CommentsWidget(
                                                                        onClose:
                                                                            () =>
                                                                                commentSideWidget.value = null,
                                                                        replyComment:
                                                                            replyComment,
                                                                        snapshot:
                                                                            commentsSnapshot,
                                                                      );
                                                                    },
                                                          title: Text(
                                                            context.locals
                                                                .comments,
                                                          ),
                                                          trailing: Text(
                                                            (commentsSnapshot
                                                                            .data !=
                                                                        null
                                                                    ? commentsSnapshot
                                                                        .data!
                                                                        .totalLength
                                                                    : 0)
                                                                .formatNumber,
                                                          ),
                                                        ),
                                                        const Divider(
                                                          height: 4,
                                                        ),
                                                        if (context.isMobile)
                                                          DescriptionWidget(
                                                            video: videoData,
                                                          ),
                                                      ],
                                                    ),
                                                    if (context.isMobile) ...[
                                                      if (commentSideWidget
                                                              .value !=
                                                          null)
                                                        commentSideWidget
                                                            .value!,
                                                      if (downloadsSideWidget
                                                              .value !=
                                                          null)
                                                        downloadsSideWidget
                                                            .value!
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (!context.isMobile)
                                        Flexible(
                                          flex: 4,
                                          child: [
                                            DescriptionWidget(
                                              video: videoData,
                                              isInsidePopup: false,
                                            ),
                                          ].last,
                                        ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
              ),
              if (!videoPlatforms)
                SizedBox(
                  height: 51,
                  child: AdwHeaderBar(
                    actions: AdwActions().bitsdojo,
                    start: [
                      context.backLeading(isCircular: true),
                    ],
                    style: const HeaderBarStyle(isTransparent: true),
                  ),
                ),
              Align(
                alignment: Alignment.topRight,
                child: Material(
                  child: SizedBox(
                    width: context.width / 3,
                    child: [
                      const SizedBox(),
                      if (!context.isMobile) ...[
                        if (commentSideWidget.value != null)
                          commentSideWidget.value!,
                        if (downloadsSideWidget.value != null)
                          downloadsSideWidget.value!,
                      ],
                    ].last,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ShowDownloadsWidget extends StatelessWidget {
  const ShowDownloadsWidget({
    Key? key,
    required this.downloadsSideWidget,
    required this.videoData,
    this.manifest,
  }) : super(key: key);

  final ValueNotifier<Widget?> downloadsSideWidget;
  final Video videoData;
  final StreamManifest? manifest;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdwHeaderBar(
          style: const HeaderBarStyle(
            autoPositionWindowButtons: false,
          ),
          title: Text(
            context.locals.downloadQuality,
          ),
          actions: AdwActions(
            onClose: () => downloadsSideWidget.value = null,
            onHeaderDrag: appWindow?.startDragging,
            onDoubleTap: appWindow?.maximizeOrRestore,
          ),
        ),
        Expanded(
          child: Container(
            color: context.theme.canvasColor,
            child: SingleChildScrollView(
              controller: ScrollController(),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              child: DownloadsWidget(
                video: videoData,
                onClose: () => downloadsSideWidget.value = null,
              ),
            ),
          ),
        ),
      ],
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
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = ref.watch(playlistProvider).playlist;
    final playlistP = ref.read(playlistProvider.notifier);
    return Column(
      children: [
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
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class CommentsWidget extends StatefulHookWidget {
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
  State<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isMounted = useIsMounted();
    final pageController = PageController();
    final _currentPage = useState<CommentsList?>(widget.snapshot.data);
    final controller = useScrollController();
    final currentPage = useState<int>(0);

    Future<void> _getMoreData() async {
      if (_currentPage.value != null &&
          isMounted() &&
          controller.position.pixels == controller.position.maxScrollExtent) {
        final page = await (_currentPage.value)!.nextPage();

        if (page == null || page.isEmpty || !isMounted()) return;

        _currentPage.value!.addAll(page);
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        _currentPage.notifyListeners();
      }
    }

    useEffect(
      () {
        controller.addListener(_getMoreData);
        return () => controller.removeListener(_getMoreData);
      },
      [controller],
    );

    return Column(
      children: [
        AdwHeaderBar(
          actions: AdwActions(
            onClose: widget.onClose ?? context.back,
            onHeaderDrag: appWindow?.startDragging,
            onDoubleTap: appWindow?.maximizeOrRestore,
          ),
          style: const HeaderBarStyle(
            autoPositionWindowButtons: false,
          ),
          start: [
            if (currentPage.value == 1)
              AdwHeaderButton(
                onPressed: () {
                  pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  );
                  widget.replyComment.value = null;
                },
                icon: Icon(
                  Icons.chevron_left,
                  color: context.textTheme.bodyText1!.color,
                ),
              )
            else
              const SizedBox(),
          ],
          title: Text(
            (currentPage.value == 0)
                ? '${(widget.snapshot.data != null ? widget.snapshot.data!.totalLength : 0).formatNumber} ${context.locals.comments.toLowerCase()}'
                : context.locals.replies,
          ),
        ),
        Expanded(
          child: Container(
            color: context.theme.canvasColor,
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
                              widget.replyComment.value = comment;
                              pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                              );
                            },
                          );
                  },
                ),
                WillPopScope(
                  child: showReplies(
                    context,
                    widget.replyComment.value,
                    EdgeInsets.symmetric(
                      horizontal: widget.onClose != null ? 16 : 0,
                    ),
                  ),
                  onWillPop: () async {
                    await pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                    widget.replyComment.value = null;
                    return false;
                  },
                ),
              ][index],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Widget showReplies(BuildContext context, Comment? comment, EdgeInsets padding) {
  final yt = YoutubeExplode();
  Future<CommentsList?>? getReplies() async {
    if (comment == null) return null;
    final replies = await yt.videos.commentsClient.getReplies(comment);
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
            FutureBuilder<List<Comment>?>(
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
              },
            ),
          ],
        )
      : getCircularProgressIndicator();
}

class DescriptionWidget extends StatelessWidget {
  const DescriptionWidget({
    Key? key,
    required this.video,
    this.isInsidePopup = true,
  }) : super(key: key);

  final bool isInsidePopup;
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
            fontWeight: FontWeight.bold,
            fontSize: isInsidePopup ? 16 : 18,
          ),
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
        Text(title, style: context.textTheme.headline3),
        Text(body),
      ],
    );
  }
}

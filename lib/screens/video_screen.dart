import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pstube/models/models.dart';
import 'package:pstube/providers/providers.dart';
import 'package:pstube/utils/utils.dart';
import 'package:pstube/widgets/video_player.dart';
import 'package:pstube/widgets/video_screen/video_screen.dart';
import 'package:pstube/widgets/vlc_player.dart';
import 'package:pstube/widgets/widgets.dart';
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
  List<RelatedVideo> recommendations = [];

  Future<void> getRecommendations() async {
    final dio = Dio();
    final cookieJar = PersistCookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    final value = await dio
        .get<String>('https://invidious.kavin.rocks/watch?v=Ahzrv1TQGHY');
    final html = parse(value.data.toString());

    final playNext = html.querySelectorAll('.pure-u-1 .pure-u-lg-1-5')[1];
    final links = playNext.querySelectorAll('div.h-box>a');
    final title = playNext.querySelectorAll('a>p');
    final uploader = playNext.querySelectorAll('h5>div>b>a');
    final views = playNext.querySelectorAll('h5>div.pure-u-10-24>b');

    for (var i = 0; i < links.length; i++) {
      final url = links[i].attributes['href'].toString();
      final channelUrl = uploader[i].attributes['href'].toString();
      final duration = links[i].querySelector('div>p.length');

      recommendations.add(
        RelatedVideo(
          url: url,
          title: title[i].innerHtml,
          uploader: uploader[i].innerHtml,
          channelUrl: channelUrl,
          duration: duration.toString(),
          views: views.toString(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getRecommendations();
  }

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
                                  final hasData =
                                      snapshot.hasData && snapshot.data != null;
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
                                              if (mobVideoPlatforms && hasData)
                                                VideoPlayer(
                                                  url: snapshot.data!.muxed
                                                      .firstWhere(
                                                        (element) => element
                                                            .qualityLabel
                                                            .contains(
                                                          '360',
                                                        ),
                                                        orElse: () => snapshot
                                                            .data!.muxed.first,
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
                                              else if (hasData)
                                                VlcPlayer(
                                                  url: snapshot.data!.muxed
                                                      .firstWhere(
                                                        (element) => element
                                                            .qualityLabel
                                                            .contains(
                                                          '360',
                                                        ),
                                                        orElse: () => snapshot
                                                            .data!.muxed.first,
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
                                                AspectRatio(
                                                  aspectRatio: 16 / 9,
                                                  child: Stack(
                                                    children: [
                                                      AspectRatio(
                                                        aspectRatio: 16 / 9,
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: videoData
                                                              .thumbnails
                                                              .mediumResUrl,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      if (mobVideoPlatforms) ...[
                                                        Container(
                                                          color: Colors.black
                                                              .withOpacity(
                                                            0.25,
                                                          ),
                                                        ),
                                                        const Align(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                      ]
                                                    ],
                                                  ),
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
                                                                    ? Icons
                                                                        .thumb_up
                                                                    : Icons
                                                                        .thumb_up_outlined,
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
                                                                icon: Icons
                                                                    .share_outlined,
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
                                                                    .download_outlined,
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
                                                                icon:
                                                                    Icons.copy,
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
                                                                icon: LucideIcons
                                                                    .listPlus,
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
              if (!mobVideoPlatforms)
                SizedBox(
                  height: 51,
                  child: AdwHeaderBar(
                    actions: AdwActions().bitsdojo,
                    start: [
                      context.backLeading(isCircular: true),
                    ],
                    style: const HeaderBarStyle(isTransparent: true),
                  ),
                )
              else
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(left: 6, top: 4),
                    child: context.backLeading(isCircular: true),
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

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:html/parser.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:pstube/data/extensions/extensions.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/data/services/services.dart';
import 'package:pstube/ui/widgets/video_screen/video_screen.dart';
import 'package:pstube/ui/widgets/widgets.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoScreen extends StatefulHookWidget {
  const VideoScreen({
    super.key,
    required this.video,
    this.videoId,
    this.loadData = false,
  }) : assert(
          videoId != null || video != null,
          "VideoId and video both can't be null",
        );

  final Video? video;
  final String? videoId;
  final bool loadData;

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
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
      final duration = links[i].querySelector('div>p.length')!.innerHtml;

      recommendations.add(
        RelatedVideo(
          url: Constants.ytCom + url,
          title: title[i].innerHtml,
          uploader: uploader[i].innerHtml,
          channelUrl: Constants.ytCom + channelUrl,
          duration: duration,
          views: views[0].innerHtml,
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
                                          child: VideoWidget(
                                            hasData: hasData,
                                            videoData: videoData,
                                            showRelatedVideo: () {},
                                            downloadsSideWidget:
                                                downloadsSideWidget,
                                            commentSideWidget:
                                                commentSideWidget,
                                            replyComment: replyComment,
                                            snapshot: snapshot,
                                            commentsSnapshot: commentsSnapshot,
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
              if (!Constants.mobVideoPlatforms)
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

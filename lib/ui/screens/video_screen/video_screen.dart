import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/extensions/extensions.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/data/services/services.dart';
import 'package:pstube/ui/screens/video_screen/src/export.dart';
import 'package:pstube/ui/widgets/widgets.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yexp;

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

  final VideoData? video;
  final String? videoId;
  final bool loadData;

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final videoId = widget.videoId ?? widget.video!.id.value;

    final videoSnapshot = widget.loadData || widget.videoId != null
        ? useFuture(
            useMemoized(
              () => PipedApi().getUnauthenticatedApi().streamInfo(
                    videoId: videoId,
                  ),
            ),
          )
        : null;
    final videoData = videoSnapshot != null &&
            videoSnapshot.data != null &&
            videoSnapshot.data!.data != null
        ? VideoData.fromVideoInfo(
            videoSnapshot.data!.data!,
            VideoId(videoId),
          )
        : widget.video;

    final replyComment = useState<Comment?>(null);
    final commentSideWidget = useState<Widget?>(null);
    final downloadsSideWidget = useState<Widget?>(null);
    final relatedVideoWidget = useState<Widget?>(null);

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            body: widget.video == null && videoSnapshot == null
                ? Center(child: Text(context.locals.videoNotFound))
                : videoData == null
                    ? getCircularProgressIndicator()
                    : FutureBuilder<Response<CommentsPage>>(
                        future: PipedApi().getUnauthenticatedApi().comments(
                              videoId: videoData.id.value,
                            ),
                        builder: (context, commentsSnapshot) {
                          return FutureBuilder<yexp.StreamManifest>(
                            future: yexp.YoutubeExplode()
                                .videos
                                .streamsClient
                                .getManifest(videoData.id),
                            builder: (context, snapshot) {
                              final hasData =
                                  snapshot.hasData && snapshot.data != null;
                              return Flex(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                direction: Axis.horizontal,
                                children: [
                                  Flexible(
                                    flex: 8,
                                    child: SFBody(
                                      child: VideoWidget(
                                        hasData: hasData,
                                        videoData: videoData,
                                        downloadsSideWidget:
                                            downloadsSideWidget,
                                        commentSideWidget: commentSideWidget,
                                        replyComment: replyComment,
                                        snapshot: snapshot,
                                        commentsSnapshot: commentsSnapshot,
                                        relatedVideoWidget: relatedVideoWidget,
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
                    if (relatedVideoWidget.value != null)
                      relatedVideoWidget.value!,
                  ],
                ].last,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

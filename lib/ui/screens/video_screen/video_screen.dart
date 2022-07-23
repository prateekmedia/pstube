import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:pstube/data/enums/enums.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/foundation/services.dart';
import 'package:pstube/foundation/view_model/video_info_view_model.dart';
import 'package:pstube/states/states.dart';
import 'package:pstube/ui/screens/video_screen/src/export.dart';
import 'package:pstube/ui/screens/video_screen/view_model/comments_view_model.dart';
import 'package:pstube/ui/widgets/widgets.dart';

class VideoScreen extends StatefulHookConsumerWidget {
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
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen>
    with AutomaticKeepAliveClientMixin {
  late final videoId = widget.videoId ?? widget.video!.id.value;
  void initVideo() {
    ref.read(videosProvider).disposeVideos();
    if (widget.loadData || widget.videoId != null) {
      ref.read(videosProvider).addVideoUrl(
            widget.videoId ?? widget.video!.id.value,
            widget.video,
          );
    } else {
      ref.read(videosProvider).addVideoData(
            widget.video!,
          );
    }
  }

  Future<void> getComments() async {
    await ref.read(commentsProvider).getComments(videoId);
  }

  @override
  void initState() {
    super.initState();
    initVideo();
    getComments();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final videoSnapshot = widget.loadData || widget.videoId != null
        ? ref.read(videoInfoProvider(VideoId(videoId)))
        : null;
    final videosP = ref.watch(videosProvider);

    final videoData = videosP.videos.isNotEmpty ? videosP.videos.last : null;

    final sideWidget = useState<Widget?>(null);
    final sideType = useState<SideType?>(null);
    final isCinemaMode =
        useState<bool>(MyPrefs().prefs.getBool('isCinema') ?? false);

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            body: widget.video == null && videoSnapshot == null
                ? Center(child: Text(context.locals.videoNotFound))
                : videoData == null
                    ? getCircularProgressIndicator()
                    : Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        direction: Axis.horizontal,
                        children: [
                          Flexible(
                            flex: 8,
                            child: SFBody(
                              child: VideoWidget(
                                videoData: videoData,
                                sideType: sideType,
                                sideWidget: sideWidget,
                                isCinemaMode: isCinemaMode,
                                emptySide: () {
                                  sideWidget.value = null;
                                  sideType.value = null;
                                },
                              ),
                            ),
                          ),
                          if (!context.isMobile && !isCinemaMode.value)
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
                      ),
          ),
          if (!Constants.mobVideoPlatforms &&
              (videoData?.videoStreams == null ||
                  (!isCinemaMode.value && !context.isMobile)))
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
          else if (videoData?.videoStreams == null)
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 6, top: 4),
                child: context.backLeading(isCircular: true),
              ),
            ),
          if (!context.isMobile && sideWidget.value != null)
            Align(
              alignment: Alignment.topRight,
              child: Material(
                child: SizedBox(
                  width: context.width / 3,
                  child: sideWidget.value,
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

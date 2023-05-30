import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video_controls/widgets/widgets.dart';

class VideoPlayerMpv extends StatefulWidget {
  const VideoPlayerMpv({
    required this.url,
    required this.audstreams,
    required this.resolutions,
    required this.isCinemaMode,
    required this.handw,
    super.key,
  });

  final ValueNotifier<bool> isCinemaMode;
  final String url;
  final Map<int, String> audstreams;
  final Map<String, String> resolutions;
  final Map<int, int> handw;

  @override
  State<VideoPlayerMpv> createState() => _VideoPlayerMpvState();
}

class _VideoPlayerMpvState extends State<VideoPlayerMpv> {
  final Player player = Player(
    configuration: const PlayerConfiguration(
      logLevel: MPVLogLevel.warn,
    ),
  );
  MediaKitController? mediaKitController;
  VideoController? videoController;

  @override
  void initState() {
    super.initState();
    mediaKitController = MediaKitController(
      player: player,
      autoPlay: true,
      looping: true,
    );

    Future.microtask(() async {
      videoController = await VideoController.create(player);
      setState(() {});
    });
  }

  @override
  void dispose() {
    player.dispose();
    videoController?.dispose();
    mediaKitController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 8,
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.all(32),
                      child: MediaKitControls(
                        controller: mediaKitController!,
                        video: Video(controller: videoController),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

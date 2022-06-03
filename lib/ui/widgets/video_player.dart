import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:pstube/data/extensions/extensions.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({
    Key? key,
    required this.url,
    required this.resolutions,
  }) : super(key: key);

  final String url;
  final Map<String, String> resolutions;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> with WidgetsBindingObserver {
  late BetterPlayerController _controller;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    mediaPlayerControllerSetUp();
    _controller.setOverriddenFit(BoxFit.contain);
  }

  void mediaPlayerControllerSetUp() {
    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoDetectFullscreenAspectRatio: true,
        fit: BoxFit.fitHeight,

        aspectRatio: 16 / 9,
        handleLifecycle: false,
        autoDetectFullscreenDeviceOrientation: true,
        // autoPlay: true,
        allowedScreenSleep: false,
        // autoDispose: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          overflowModalColor: context.getBackgroundColor.withOpacity(0.9),
          overflowMenuIconsColor: context.textTheme.bodyText1!.color!,
          overflowModalTextColor: context.textTheme.bodyText1!.color!,
          playIcon: Icons.play_arrow,
          playerTheme: BetterPlayerTheme.material,
          loadingWidget: const CircularProgressIndicator(),
          progressBarPlayedColor: context.theme.primaryColor.withOpacity(0.92),
          progressBarBufferedColor: Colors.grey,
          progressBarHandleColor: context.theme.primaryColor,
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.url,
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
          minBufferMs: 60000,
          maxBufferMs: 555000,
        ),
        resolutions: widget.resolutions,
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          preCacheSize: 400000,
          maxCacheSize: 400000,
          maxCacheFileSize: 400000,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    _controller
      ..clearCache()
      ..dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BetterPlayer(controller: _controller);
  }
}

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sftube/utils/utils.dart';

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

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    WidgetsBinding.instance!.addObserver(this);

    mediaPlayerControllerSetUp();
    _controller.setOverriddenFit(BoxFit.contain);
  }

  final indicator = const CircularProgressIndicator();

  void mediaPlayerControllerSetUp() {
    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoDetectFullscreenAspectRatio: true,
        fit: BoxFit.fitHeight,
        aspectRatio: 16 / 9,
        handleLifecycle: false,
        autoDetectFullscreenDeviceOrientation: true,
        autoPlay: true,
        allowedScreenSleep: false,
        // autoDispose: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          overflowModalColor: Colors.black87,
          overflowMenuIconsColor: Colors.white,
          overflowModalTextColor: Colors.white,
          playIcon: Icons.play_arrow,
          playerTheme: BetterPlayerTheme.cupertino,
          controlBarColor: context.theme.primaryColor.withOpacity(.75),
          loadingWidget: indicator,
          progressBarPlayedColor: context.theme.primaryColor,
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _controller.setControlsAlwaysVisible(true);
        break;
      case AppLifecycleState.inactive:
        _controller.pause();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    _controller
      ..clearCache()
      ..dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BetterPlayer(controller: _controller);
  }
}

import 'dart:math';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/widgets/video_player_desktop/controls_wrapper_desktop.dart';
import 'package:pstube/ui/widgets/video_player_desktop/states/player_state_provider.dart';
import 'package:window_manager/window_manager.dart';

class VideoPlayerDesktop extends StatefulWidget {
  const VideoPlayerDesktop({
    super.key,
    required this.url,
    required this.resolutions,
    required this.isCinemaMode,
  });

  final ValueNotifier<bool> isCinemaMode;
  final String url;
  final Map<String, String> resolutions;

  @override
  State<VideoPlayerDesktop> createState() => _VideoPlayerDesktopState();
}

class _VideoPlayerDesktopState extends State<VideoPlayerDesktop>
    with WidgetsBindingObserver {
  Player player = Player(id: 0);
  CurrentState current = CurrentState();
  PositionState position = PositionState();
  PlaybackState playback = PlaybackState();
  GeneralState general = GeneralState();
  VideoDimensions videoDimensions = const VideoDimensions(0, 0);
  late List<Media> medias = <Media>[Media.network(widget.url)];
  List<Device> devices = <Device>[];
  double bufferingProgress = 0;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      player.currentStream.listen((current) {
        setState(() => this.current = current);
      });

      player.positionStream.listen((position) {
        setState(() => this.position = position);
      });
      player.playbackStream.listen((playback) {
        setState(() => this.playback = playback);
      });
      player.generalStream.listen((general) {
        setState(() => this.general = general);
      });
      player.videoDimensionsStream.listen((videoDimensions) {
        setState(() => this.videoDimensions = videoDimensions);
      });
      player.bufferingProgressStream.listen(
        (bufferingProgress) {
          setState(() => this.bufferingProgress = bufferingProgress);
        },
      );
      player.open(Playlist(medias: medias));
      player.errorStream.listen((event) {
        debugPrint('⚠️⚠️⚠️ libVLC error received.');
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    player.dispose();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    devices = Devices.all;
    final equalizer = Equalizer.createMode(EqualizerMode.live)
      ..setPreAmp(10)
      ..setBandAmp(31.25, 10);
    player.setEqualizer(equalizer);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _VideoDesktop(
      player: player,
      isCinemaMode: widget.isCinemaMode,
    );
  }
}

class _VideoDesktop extends ConsumerWidget {
  const _VideoDesktop({
    required this.player,
    this.isFullScreen = false,
    this.isCinemaMode,
  });

  final Player player;
  final bool isFullScreen;
  final ValueNotifier<bool>? isCinemaMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boxFit = ref.watch(playerStateProvider.notifier).boxFit;

    Future<void> enterFullscreen() async {
      final navigator = Navigator.of(context, rootNavigator: true);

      await windowManager.ensureInitialized();
      await windowManager.setFullScreen(true);

      await navigator.push(
        PageRouteBuilder<dynamic>(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => Scaffold(
            body: Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black,
              child: _VideoDesktop(
                player: player,
                isFullScreen: true,
              ),
            ),
          ),
        ),
      );
    }

    Future<void> exitFullscreen() async {
      final navigator = Navigator.of(context);

      await windowManager.ensureInitialized();
      await windowManager.setFullScreen(false);

      navigator.pop();
    }

    ControlsDesktopData data(
      BuildContext context, {
      bool isFullscreen = false,
    }) =>
        ControlsDesktopData(
          showWindowControls:
              !isFullscreen && (context.isMobile || isCinemaMode!.value),
          showTimeLeft: false,
          isFullscreen: isFullscreen,
          onFullscreenTap: isFullscreen ? exitFullscreen : enterFullscreen,
        );

    ControlsDesktopStyle style(BuildContext context) => ControlsDesktopStyle(
          progressBarThumbRadius: 10,
          progressBarThumbGlowRadius: 15,
          progressBarActiveColor: context.theme.primaryColor.brighten(context),
          progressBarInactiveColor: Colors.white24,
          progressBarThumbColor: Colors.white,
          progressBarThumbGlowColor: const Color.fromRGBO(0, 161, 214, .2),
          volumeActiveColor: context.theme.primaryColor.brighten(context),
          volumeInactiveColor: Colors.grey,
          volumeBackgroundColor: context.getAltBackgroundColor,
          volumeThumbColor: Colors.white,
          progressBarTextStyle: const TextStyle(),
        );

    Widget videoWidget(
      BuildContext context, {
      bool isFullScreen = false,
    }) =>
        Video(
          showControls: false,
          progressBarThumbGlowColor: Colors.red.withOpacity(0.2),
          progressBarThumbColor: Colors.red,
          progressBarActiveColor: Colors.red,
          fit: boxFit,
          player: player,
          height: !isFullScreen
              ? min(context.height * 0.45, context.width * 9 / 16)
              : null,
          volumeThumbColor: Colors.blue,
          volumeActiveColor: Colors.blue,
        );

    return ControlsWrapperDesktop(
      player: player,
      style: style(context),
      data: data(
        context,
        isFullscreen: isFullScreen,
      ),
      child: videoWidget(context, isFullScreen: isFullScreen),
    );
  }
}

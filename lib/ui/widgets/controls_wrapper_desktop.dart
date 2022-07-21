import 'dart:async';

import 'package:adwaita/adwaita.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:pstube/foundation/extensions/context/extension.dart';

class ControlsDesktopData {
  ControlsDesktopData({
    this.isFullscreen = false,
    required this.onFullscreenTap,
    this.showWindowControls = false,
    required this.showTimeLeft,
  });

  final VoidCallback onFullscreenTap;
  final bool isFullscreen;
  final bool showWindowControls;
  final bool? showTimeLeft;
}

class ControlsDesktopStyle {
  ControlsDesktopStyle({
    this.progressBarThumbRadius,
    this.progressBarThumbGlowRadius,
    this.progressBarActiveColor,
    this.progressBarInactiveColor,
    this.progressBarThumbColor,
    this.progressBarThumbGlowColor,
    this.progressBarTextStyle,
    this.volumeActiveColor,
    this.volumeInactiveColor,
    this.volumeBackgroundColor,
    this.volumeThumbColor,
  });

  final double? progressBarThumbRadius;
  final double? progressBarThumbGlowRadius;
  final Color? progressBarActiveColor;
  final Color? progressBarInactiveColor;
  final Color? progressBarThumbColor;
  final Color? progressBarThumbGlowColor;
  final TextStyle? progressBarTextStyle;
  final Color? volumeActiveColor;
  final Color? volumeInactiveColor;
  final Color? volumeBackgroundColor;
  final Color? volumeThumbColor;
}

class ControlsWrapperDesktop extends HookWidget {
  const ControlsWrapperDesktop({
    super.key,
    required this.child,
    required this.player,
    required this.data,
    required this.style,
  });

  final Widget child;
  final Player player;
  final ControlsDesktopData data;
  final ControlsDesktopStyle style;

  @override
  Widget build(BuildContext context) {
    final _hideControls = useState<bool>(false);
    final _displayTapped = useState<bool>(false);
    final isMounted = useIsMounted();

    final _hideTimer = useState<Timer?>(null);
    late StreamSubscription<PlaybackState> playPauseStream;
    final playPauseController = useAnimationController(
      duration: const Duration(milliseconds: 400),
    );

    void setPlaybackMode({required bool isPlaying}) {
      if (isPlaying) {
        playPauseController.forward();
      } else {
        playPauseController.reverse();
      }
    }

    void _startHideTimer() {
      _hideTimer.value = Timer(const Duration(seconds: 2), () {
        if (!isMounted()) return;
        _hideControls.value = true;
      });
    }

    void _cancelAndRestartTimer() {
      if (_hideTimer.value != null) {
        _hideTimer.value!.cancel();
        _hideTimer.value = null;
      }

      if (!isMounted()) return;
      _startHideTimer();

      _hideControls.value = false;
      _displayTapped.value = true;
    }

    useEffect(
      () {
        playPauseStream = player.playbackStream
            .listen((event) => setPlaybackMode(isPlaying: event.isPlaying));
        if (player.playback.isPlaying) playPauseController.forward();
        return () {
          playPauseStream.cancel();
        };
      },
      [player],
    );

    return GestureDetector(
      onTap: () {
        if (!player.playback.isPlaying) {
          _hideControls.value = true;
          return;
        }

        if (!_displayTapped.value) {
          _cancelAndRestartTimer();
          return;
        }

        _hideControls.value = !_hideControls.value;
      },
      child: MouseRegion(
        onHover: (_) => _cancelAndRestartTimer(),
        child: AbsorbPointer(
          absorbing: _hideControls.value,
          child: Stack(
            children: [
              child,
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _hideControls.value ? 0.0 : 1.0,
                  child: Stack(
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xCC000000),
                              Color(0x00000000),
                              Color(0x00000000),
                              Color(0x00000000),
                              Color(0x00000000),
                              Color(0x00000000),
                              Color(0xCC000000),
                            ],
                          ),
                        ),
                      ),
                      if (!data.isFullscreen && data.showWindowControls)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: SizedBox(
                            height: 51,
                            child: Theme(
                              data: AdwaitaThemeData.dark(),
                              child: AdwHeaderBar(
                                actions: AdwActions().bitsdojo,
                                start: [
                                  Theme(
                                    data: AdwaitaThemeData.light(),
                                    child: context.backLeading(
                                      isCircular: true,
                                    ),
                                  ),
                                ],
                                style:
                                    const HeaderBarStyle(isTransparent: true),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 60,
                            right: 20,
                            left: 20,
                          ),
                          child: StreamBuilder<PositionState>(
                            stream: player.positionStream,
                            builder: (
                              BuildContext context,
                              AsyncSnapshot<PositionState> snapshot,
                            ) {
                              final durationState = snapshot.data;
                              final progress =
                                  durationState?.position ?? Duration.zero;
                              final total =
                                  durationState?.duration ?? Duration.zero;
                              return Theme(
                                data: ThemeData.dark(),
                                child: ProgressBar(
                                  progress: progress,
                                  total: total,
                                  barHeight: 3,
                                  progressBarColor:
                                      style.progressBarActiveColor,
                                  thumbColor: style.progressBarThumbColor,
                                  baseBarColor: style.progressBarInactiveColor,
                                  thumbGlowColor:
                                      style.progressBarThumbGlowColor,
                                  thumbRadius:
                                      style.progressBarThumbRadius ?? 10.0,
                                  thumbGlowRadius:
                                      style.progressBarThumbGlowRadius ?? 30.0,
                                  timeLabelLocation: TimeLabelLocation.none,
                                  timeLabelType: data.showTimeLeft!
                                      ? TimeLabelType.remainingTime
                                      : TimeLabelType.totalTime,
                                  timeLabelTextStyle:
                                      style.progressBarTextStyle,
                                  onSeek: player.seek,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      StreamBuilder<CurrentState>(
                        stream: player.currentStream,
                        builder: (context, snapshot) {
                          return Positioned(
                            left: 0,
                            right: 0,
                            bottom: 10,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 10),
                                if ((snapshot.data?.medias.length ?? 0) > 1)
                                  IconButton(
                                    color: Colors.white,
                                    iconSize: 30,
                                    icon: const Icon(Icons.skip_previous),
                                    onPressed: player.previous,
                                  ),
                                IconButton(
                                  color: Colors.white,
                                  iconSize: 30,
                                  icon: AnimatedIcon(
                                    icon: AnimatedIcons.play_pause,
                                    progress: playPauseController,
                                  ),
                                  onPressed: () {
                                    if (player.playback.isPlaying) {
                                      player.pause();
                                      playPauseController.reverse();
                                    } else {
                                      player.play();
                                      playPauseController.forward();
                                    }
                                  },
                                ),
                                const SizedBox(width: 20),
                                if ((snapshot.data?.medias.length ?? 0) > 1)
                                  IconButton(
                                    color: Colors.white,
                                    iconSize: 30,
                                    icon: const Icon(Icons.skip_next),
                                    onPressed: player.next,
                                  ),
                                VolumeControl(
                                  player: player,
                                  thumbColor: style.volumeThumbColor,
                                  inactiveColor: style.volumeInactiveColor,
                                  activeColor: style.volumeActiveColor,
                                  backgroundColor: style.volumeBackgroundColor,
                                ),
                                Text(
                                  'data',
                                  style: context.textTheme.bodyText1!
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: 15,
                        bottom: 12.5,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AdwButton.circular(
                              onPressed: data.onFullscreenTap,
                              child: Icon(
                                !data.isFullscreen
                                    ? Icons.fullscreen
                                    : Icons.fullscreen_exit,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VolumeControl extends HookWidget {
  const VolumeControl({
    required this.player,
    required this.activeColor,
    required this.inactiveColor,
    required this.backgroundColor,
    required this.thumbColor,
    super.key,
  });

  final Player player;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final Color? thumbColor;

  @override
  Widget build(BuildContext context) {
    final volume = useState<double>(player.general.volume);
    final _showVolume = useState<bool>(false);
    final unmutedVolume = useState<double>(0.5);

    void muteUnmute() {
      if (player.general.volume > 0) {
        unmutedVolume.value = player.general.volume;
        player.setVolume(0);
      } else {
        player.setVolume(unmutedVolume.value);
      }
    }

    return SizedBox(
      height: 45,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            onEnter: (_) => _showVolume.value = true,
            onExit: (_) => _showVolume.value = false,
            child: AdwButton.circular(
              onPressed: muteUnmute,
              child: Icon(
                getIcon(),
                size: 26,
                color: Colors.white,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _showVolume.value
                ? AbsorbPointer(
                    absorbing: !_showVolume.value,
                    child: MouseRegion(
                      onEnter: (_) => _showVolume.value = true,
                      onExit: (_) => _showVolume.value = false,
                      child: SizedBox(
                        width: 120,
                        height: 45,
                        child: SliderTheme(
                          data: SliderThemeData(
                            overlayShape: SliderComponentShape.noThumb,
                            activeTrackColor: activeColor,
                            inactiveTrackColor: inactiveColor,
                            thumbColor: thumbColor,
                          ),
                          child: Slider(
                            value: volume.value,
                            onChanged: (vol) {
                              player.setVolume(vol);
                              volume.value = vol;
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  IconData getIcon() {
    if (player.general.volume > .5) {
      return Icons.volume_up_sharp;
    } else if (player.general.volume > 0) {
      return Icons.volume_down_sharp;
    } else {
      return Icons.volume_off_sharp;
    }
  }
}

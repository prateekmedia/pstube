import 'dart:async';

import 'package:adwaita/adwaita.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
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

class ControlsWrapperDesktop extends StatefulWidget {
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
  State<ControlsWrapperDesktop> createState() => _ControlsWrapperDesktopState();
}

class _ControlsWrapperDesktopState extends State<ControlsWrapperDesktop>
    with SingleTickerProviderStateMixin {
  bool _hideControls = false;
  bool _displayTapped = false;
  Timer? _hideTimer;
  late StreamSubscription<PlaybackState> playPauseStream;
  late AnimationController playPauseController;

  Player get player => widget.player;

  @override
  void initState() {
    super.initState();
    playPauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    playPauseStream = player.playbackStream
        .listen((event) => setPlaybackMode(isPlaying: event.isPlaying));
    if (player.playback.isPlaying) playPauseController.forward();
  }

  @override
  void dispose() {
    playPauseStream.cancel();
    playPauseController.dispose();
    super.dispose();
  }

  void setPlaybackMode({required bool isPlaying}) {
    if (isPlaying) {
      playPauseController.forward();
    } else {
      playPauseController.reverse();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (player.playback.isPlaying) {
          if (_displayTapped) {
            setState(() => _hideControls = true);
          } else {
            _cancelAndRestartTimer();
          }
        } else {
          setState(() => _hideControls = true);
        }
      },
      child: MouseRegion(
        onHover: (_) => _cancelAndRestartTimer(),
        child: AbsorbPointer(
          absorbing: _hideControls,
          child: Stack(
            children: [
              widget.child,
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _hideControls ? 0.0 : 1.0,
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
                      if (!widget.data.isFullscreen &&
                          widget.data.showWindowControls)
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
                                      widget.style.progressBarActiveColor,
                                  thumbColor:
                                      widget.style.progressBarThumbColor,
                                  baseBarColor:
                                      widget.style.progressBarInactiveColor,
                                  thumbGlowColor:
                                      widget.style.progressBarThumbGlowColor,
                                  thumbRadius:
                                      widget.style.progressBarThumbRadius ??
                                          10.0,
                                  thumbGlowRadius:
                                      widget.style.progressBarThumbGlowRadius ??
                                          30.0,
                                  timeLabelLocation: TimeLabelLocation.none,
                                  timeLabelType: widget.data.showTimeLeft!
                                      ? TimeLabelType.remainingTime
                                      : TimeLabelType.totalTime,
                                  timeLabelTextStyle:
                                      widget.style.progressBarTextStyle,
                                  onSeek: (duration) {
                                    player.seek(duration);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      StreamBuilder<CurrentState>(
                        stream: widget.player.currentStream,
                        builder: (context, snapshot) {
                          return Positioned(
                            left: 0,
                            right: 0,
                            bottom: 10,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(width: 10),
                                if ((snapshot.data?.medias.length ?? 0) > 1)
                                  IconButton(
                                    color: Colors.white,
                                    iconSize: 30,
                                    icon: const Icon(Icons.skip_previous),
                                    onPressed: () => player.previous(),
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
                                    onPressed: () => player.next(),
                                  ),
                                VolumeControl(
                                  player: player,
                                  thumbColor: widget.style.volumeThumbColor,
                                  inactiveColor:
                                      widget.style.volumeInactiveColor,
                                  activeColor: widget.style.volumeActiveColor,
                                  backgroundColor:
                                      widget.style.volumeBackgroundColor,
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
                              onPressed: widget.data.onFullscreenTap,
                              child: Icon(
                                !widget.data.isFullscreen
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

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();

    if (mounted) {
      _startHideTimer();

      setState(() {
        _hideControls = false;
        _displayTapped = true;
      });
    }
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _hideControls = true;
        });
      }
    });
  }
}

class VolumeControl extends StatefulWidget {
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
  _VolumeControlState createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  double volume = 0.5;
  bool _showVolume = false;
  double unmutedVolume = 0.5;

  Player get player => widget.player;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            onEnter: (_) {
              setState(() => _showVolume = true);
            },
            onExit: (_) {
              setState(() => _showVolume = false);
            },
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
            child: _showVolume
                ? AbsorbPointer(
                    absorbing: !_showVolume,
                    child: MouseRegion(
                      onEnter: (_) {
                        setState(() => _showVolume = true);
                      },
                      onExit: (_) {
                        setState(() => _showVolume = false);
                      },
                      child: SizedBox(
                        width: 250,
                        height: 45,
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: widget.activeColor,
                            inactiveTrackColor: widget.inactiveColor,
                            thumbColor: widget.thumbColor,
                          ),
                          child: Slider(
                            value: player.general.volume,
                            onChanged: (volume) {
                              player.setVolume(volume);
                              setState(() {});
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

  void muteUnmute() {
    if (player.general.volume > 0) {
      unmutedVolume = player.general.volume;
      player.setVolume(0);
    } else {
      player.setVolume(unmutedVolume);
    }
    setState(() {});
  }
}

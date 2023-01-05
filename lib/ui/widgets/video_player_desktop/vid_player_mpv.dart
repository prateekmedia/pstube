import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_core_video/media_kit_core_video.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/widgets/video_player_desktop/controls_wrapper_desktop.dart';
import 'package:pstube/ui/widgets/video_player_desktop/states/player_state_provider.dart';
import 'package:window_manager/window_manager.dart';

class VideoPlayerMpv extends StatefulWidget {
  const VideoPlayerMpv({
    super.key,
    required this.url,
    required this.resolutions,
    required this.isCinemaMode,
  });

  final ValueNotifier<bool> isCinemaMode;
  final String url;
  final Map<String, String> resolutions;

  @override
  EventDesktopPlayerState createState() => EventDesktopPlayerState();

}

//begin seekbar
class SeekBar extends StatefulWidget {
  final Player player;
  const SeekBar({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  double volume = 0.5;

  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    isPlaying = widget.player.state.isPlaying;
    position = widget.player.state.position;
    duration = widget.player.state.duration;
    volume = widget.player.state.volume;
    
    subscriptions.addAll(
      [
        widget.player.streams.isPlaying.listen((event) {
          setState(() {
            isPlaying = event;
          });
        }),
        widget.player.streams.position.listen((event) {
          setState(() {
            position = event;
          });
        }),
        widget.player.streams.duration.listen((event) {
          setState(() {
            duration = event;
          });
        }),
        widget.player.streams.volume.listen((event) {
          setState(() {
            volume = event;
          });
        }),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final s in subscriptions) {
      s.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: widget.player.playOrPause,
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            color: Theme.of(context).toggleableActiveColor,
            iconSize: 36.0,
          ),
          Text(position.toString().substring(2, 7)),
          Expanded(
            child: Slider(
              min: 0.0,
              max: duration.inMilliseconds.toDouble(),
              value: position.inMilliseconds.toDouble().clamp(
                    0,
                    duration.inMilliseconds.toDouble(),
                  ),
              onChanged: (e) {
                setState(() {
                  position = Duration(milliseconds: e ~/ 1);
                });
              },
              onChangeEnd: (e) {
                widget.player.seek(Duration(milliseconds: e ~/ 1));
              },
            ),
          ),
          //Text(duration.toString().substring(2, 7)),
          //IconButton(
          //  onPressed: ,
          //  icon: Icon(
          //    volume = 0.0 ? Icons.volume_off : Icons.volume_up,
          //  ),
          //  color: Theme.of(context).primaryColor,
          //  iconSize: 36.0,
          //),
        ],
      )
      
    );
  }
}
//end seekbar

class EventDesktopPlayerState extends State<VideoPlayerMpv> {

      // Create a [Player] instance from `package:media_kit`.
  final Player player = Player();
  // Reference to the [VideoController] instance from `package:media_kit_core_video`.
  VideoController? controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller = await VideoController.create(player.handle);
      setState(() {});
    });
  }

  bool _isDownloading = false;
  bool Triggered = false;
  bool isVisible = false;
  String? url;
  late List<Media> medias = <Media>[Media(widget.url)];
  

    void _downloadAction() async {
      
      await player.open(Playlist(medias));

      setState(() => _isDownloading = false);
      setState(() => Triggered = true);
    }

    @override
  void dispose() {
    Future.microtask(() async {
      await controller?.dispose();
      await player.dispose();
    });;
    super.dispose();
  }
    @override
  Widget build(BuildContext context) {

    return Material(
      color: Color.fromARGB(0, 0, 0, 0),
      child: ConstrainedBox(
        //TODO: make height customizable, figure out ratio from mpv needs set to proper align with side.
        constraints: BoxConstraints(maxHeight: 300, maxWidth: 16 / 9 * 300), 
        child: Triggered == true
            ? Stack(
              //alignment: Alignment.bottomCenter,
              children: [
                  Center(child: Video(controller: controller)),
                  if(isVisible)
                  Container(
                    child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      color: Color.fromARGB(125, 0, 0, 0),
                      child: SeekBar(player: player),
                    )
                  )
                ),
                MouseRegion(
                  onEnter: (PointerEvent details)=>setState(()=>isVisible = true),
                  onExit: (PointerEvent details)=>setState(()=>isVisible = false),
                  opaque: false,
                )
              ]
            )
            : //Stack(
                //children: [
                  Center(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ),
                      icon: _isDownloading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2),
                            )
                          : const Icon(Icons.download_outlined),
                        label: Text("test"),
                      onPressed: _downloadAction,
                    ),
                  )
                //],
              ),
      );

  }
}
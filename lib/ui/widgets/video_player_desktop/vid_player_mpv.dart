import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
  // Create a [Player] to control playback.
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);
  late List<Media> medias = <Media>[Media(widget.url)];
  late Map<int, String> aud = widget.audstreams;
  late Map<String, String> res = widget.resolutions;
  late Map<int, int> aspect = widget.handw;
  late double aspectvalue;
  late String quality = 'Auto';

  @override
  void initState() {
    super.initState();
    _selectResolution(widget.resolutions.values.first);
  }

  Future<void> _selectResolution(String vid) async {
    // The maximum bitrate is needed to select the best audio quality
    final maxBitrate = aud.keys.reduce(max);
    // The audio URL is needed to load the audio track
    final audioUrl = aud[maxBitrate]!;

    if (player.platform != null && player.platform is libmpvPlayer) {
      try {
        // The audio track is appended to the video track using the libmpvPlayer method
        await (player.platform! as libmpvPlayer).setProperty(
          'audio-files',
          Platform.isWindows
              ? audioUrl.replaceAll(';', r'\;')
              : audioUrl.replaceAll(':', r'\:'),
        );
      } catch (e) {
        debugPrint('External Audio error: $e');
      }
    }

    // The playlist with both audio and video tracks is opened by the player
    // await player.open(Playlist(medias));
    // Alternatively, only the video track can be opened by the player
    await player.open(Playlist([Media(vid)]));

    setState(() {
      final aspectlist = aspect.entries.toList();
      final h = aspectlist[0].key;
      final w = aspectlist[0].value;

      aspectvalue = h / w;
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 500,
        // Use [Video] widget to display video output.
        child: MaterialDesktopVideoControlsTheme(
          fullscreen: MaterialDesktopVideoControlsThemeData(
            bottomButtonBar: [
              const MaterialDesktopSkipPreviousButton(),
              const MaterialDesktopPlayOrPauseButton(),
              const MaterialDesktopSkipNextButton(),
              const MaterialDesktopVolumeButton(),
              const MaterialDesktopPositionIndicator(),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                ),
                onPressed: () {
                  showDialog<dynamic>(
                    context: context,
                    builder: (context) {
                      return resolutionDialog();
                    },
                  );
                },
                child: Text(quality),
              ),
              const MaterialDesktopFullscreenButton(),
            ],
          ),
          normal: MaterialDesktopVideoControlsThemeData(
            bottomButtonBar: [
              const MaterialDesktopSkipPreviousButton(),
              const MaterialDesktopPlayOrPauseButton(),
              const MaterialDesktopSkipNextButton(),
              const MaterialDesktopVolumeButton(),
              const MaterialDesktopPositionIndicator(),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                ),
                onPressed: () {
                  showDialog<dynamic>(
                    context: context,
                    builder: (context) {
                      return resolutionDialog();
                    },
                  );
                },
                child: Text(quality),
              ),
              const MaterialDesktopFullscreenButton(),
            ],
          ),
          child: Video(
            controller: controller,
          ),
        ),
      ),
    );
  }

  SimpleDialog resolutionDialog() {
    return SimpleDialog(
      title: const Text('Resolutions'),
      children: res.entries.map((entry) {
        final w = InkWell(
          onTap: () {
            setState(() {
              quality = entry.key;
            });
            _selectResolution(entry.value);
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              entry.key,
            ),
          ),
        );

        return w;
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';

class VideoPlayerMobile extends StatefulWidget {
  const VideoPlayerMobile({
    super.key,
    required this.defaultQuality,
    required this.resolutions,
  });

  final int defaultQuality;
  final Map<String, String> resolutions;

  @override
  State<VideoPlayerMobile> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayerMobile>
    with WidgetsBindingObserver {
  late PodPlayerController _controller;

  @override
  void initState() {
    super.initState();

    mediaPlayerControllerSetUp();
  }

  void mediaPlayerControllerSetUp() {
    _controller = PodPlayerController(
      podPlayerConfig: PodPlayerConfig(
        initialVideoQuality: widget.defaultQuality,
      ),
      playVideoFrom: PlayVideoFrom.networkQualityUrls(
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: true,
        ),
        videoUrls: widget.resolutions.entries
            .map(
              (entry) => VideoQalityUrls(
                quality: int.tryParse(
                      entry.key.substring(0, entry.key.length - 1),
                    ) ??
                    0,
                url: entry.value,
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PodVideoPlayer(
      controller: _controller,
    );
  }
}

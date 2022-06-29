import 'package:flutter/material.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/data/services/services.dart';
import 'package:pstube/ui/widgets/video_player.dart';
import 'package:pstube/ui/widgets/vlc_player.dart';

class PlatformVideoPlayer extends StatelessWidget {
  const PlatformVideoPlayer({super.key, required this.videoData});

  final VideoData videoData;

  @override
  Widget build(BuildContext context) {
    final videoStreams = videoData.videoStreams!
        .where(
          (p0) => !(p0.videoOnly ?? false),
        )
        .toList();

    return (Constants.mobVideoPlatforms)
        ? VideoPlayer(
            url: videoStreams
                .firstWhere(
                  (element) => element.quality!.contains(
                    '360',
                  ),
                  orElse: () => videoStreams.first,
                )
                .url
                .toString(),
            resolutions: videoStreams.asMap().map(
                  (key, value) => MapEntry(
                    value.quality!,
                    value.url.toString(),
                  ),
                ),
          )
        : VlcPlayer(
            url: videoStreams
                .firstWhere(
                  (element) => element.quality!.contains(
                    '360',
                  ),
                  orElse: () => videoStreams.first,
                )
                .url
                .toString(),
            resolutions: videoStreams.asMap().map(
                  (key, value) => MapEntry(
                    value.quality!,
                    value.url.toString(),
                  ),
                ),
          );
  }
}

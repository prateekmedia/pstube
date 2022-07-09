import 'package:flutter/material.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/data/services/services.dart';
import 'package:pstube/ui/widgets/video_player_desktop.dart';
import 'package:pstube/ui/widgets/video_player_mobile.dart';

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
        ? VideoPlayerMobile(
            defaultQuality: 360,
            resolutions: videoStreams.asMap().map(
                  (key, value) => MapEntry(
                    value.quality!,
                    value.url.toString(),
                  ),
                ),
          )
        : VideoPlayerDesktop(
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

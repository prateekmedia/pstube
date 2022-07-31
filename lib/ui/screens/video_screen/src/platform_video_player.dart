import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/foundation/services.dart';
import 'package:pstube/ui/widgets/video_player_desktop/video_player_desktop.dart';
import 'package:pstube/ui/widgets/video_player_mobile.dart';

class PlatformVideoPlayer extends StatelessWidget {
  const PlatformVideoPlayer({
    super.key,
    required this.videoData,
    required this.isCinemaMode,
  });

  final ValueNotifier<bool> isCinemaMode;
  final VideoData videoData;

  @override
  Widget build(BuildContext context) {
    final videoStreams = videoData.videoStreams!
        .where(
          (p0) => !(p0.videoOnly ?? false),
        )
        .toList();

    return Constants.isMobileOrWeb
        ? VideoPlayerMobile(
            defaultQuality: 360,
            resolutions: videoStreams
                .map(
                  (value) => VideoQalityUrls(
                    quality: int.tryParse(
                          value.quality!
                              .substring(0, value.quality!.length - 1),
                        ) ??
                        0,
                    url: value.url.toString(),
                  ),
                )
                .toList(),
          )
        : VideoPlayerDesktop(
            isCinemaMode: isCinemaMode,
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

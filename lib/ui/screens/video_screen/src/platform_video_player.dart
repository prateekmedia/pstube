import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/foundation/services.dart';
import 'package:pstube/ui/widgets/video_player_desktop/vid_player_mpv.dart';
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
    final videoonlyStreams = videoData.videoStreams!
        .where(
          (p0) => !(p0.videoOnly == false),
        )
        .toList();
    final audioonlyStreams = videoData.audioStreams!
        .where(
          (p0) => (p0.codec == "opus"), //TODO: make this customizable
        )
        .toList();

    if (Constants.isMobileOrWeb) {
        return VideoPlayerMobile(
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
          );
        } else if (Constants.isWindows){ 
        return VideoPlayerMpv(
            isCinemaMode: isCinemaMode,
            url: videoStreams.last.url.toString(),
            audstreams: audioonlyStreams.asMap().map(
                  (key, value) => MapEntry(
                    value.bitrate!,
                    value.url.toString(),
                  ),
                ),
            resolutions: videoonlyStreams.asMap().map(
                  (key, value) => MapEntry(
                    value.quality!,
                    value.url.toString(),
                  ),
                ),
            handw: videoonlyStreams.asMap().map(
                  (key, value) => MapEntry(
                    value.width!,
                    value.height!,
                  ),
            ),
          );
        } else {
          return VideoPlayerDesktop(
            isCinemaMode: isCinemaMode,
            url: videoStreams.last.url.toString(),
            resolutions: videoStreams.asMap().map(
                  (key, value) => MapEntry(
                    value.quality!,
                    value.url.toString(),
                  ),
                ),
          );
        };
  }
}

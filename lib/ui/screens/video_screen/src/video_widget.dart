import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/enums/enums.dart';
import 'package:pstube/data/extensions/extensions.dart';
import 'package:pstube/data/models/video_data.dart';
import 'package:pstube/data/services/services.dart';
import 'package:pstube/ui/screens/video_screen/src/export.dart';
import 'package:pstube/ui/widgets/channel_details.dart';
import 'package:pstube/ui/widgets/video_player.dart';
import 'package:pstube/ui/widgets/vlc_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yexp;

class VideoWidget extends StatelessWidget {
  const VideoWidget({
    super.key,
    required this.hasData,
    required this.videoData,
    required this.sideType,
    required this.sideWidget,
    required this.replyComment,
    required this.snapshot,
    required this.commentsSnapshot,
    required this.emptySide,
  });

  final bool hasData;
  final VideoData videoData;
  final ValueNotifier<SideType?> sideType;
  final ValueNotifier<Widget?> sideWidget;
  final ValueNotifier<Comment?> replyComment;
  final AsyncSnapshot<yexp.StreamManifest> snapshot;
  final AsyncSnapshot<Response<CommentsPage>> commentsSnapshot;
  final VoidCallback emptySide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (Constants.mobVideoPlatforms && hasData)
          VideoPlayer(
            url: snapshot.data!.muxed
                .firstWhere(
                  (element) => element.qualityLabel.contains(
                    '360',
                  ),
                  orElse: () => snapshot.data!.muxed.first,
                )
                .url
                .toString(),
            resolutions: snapshot.data!.muxed.asMap().map(
                  (key, value) => MapEntry(
                    value.qualityLabel,
                    value.url.toString(),
                  ),
                ),
          )
        else if (hasData)
          VlcPlayer(
            url: snapshot.data!.muxed
                .firstWhere(
                  (element) => element.qualityLabel.contains(
                    '360',
                  ),
                  orElse: () => snapshot.data!.muxed.first,
                )
                .url
                .toString(),
            resolutions: snapshot.data!.muxed.asMap().map(
                  (key, value) => MapEntry(
                    value.qualityLabel,
                    value.url.toString(),
                  ),
                ),
          )
        else
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: videoData.thumbnails.mediumResUrl,
                    fit: BoxFit.fill,
                  ),
                ),
                if (Constants.mobVideoPlatforms) ...[
                  ColoredBox(
                    color: Colors.black.withOpacity(0.25),
                  ),
                  const Align(
                    child: CircularProgressIndicator(),
                  ),
                ]
              ],
            ),
          ),
        Flexible(
          child: Stack(
            children: [
              ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          videoData.title!,
                          style: context.textTheme.headline3,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              '${videoData.views?.formatNumber ?? 0}'
                              ' views',
                            ),
                            Text(
                              videoData.uploadDate != null
                                  ? '  •  ${videoData.uploadDate!}'
                                  : '',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  VideoActions(
                    snapshot: snapshot,
                    videoData: videoData,
                    sideType: sideType,
                    sideWidget: sideWidget,
                    emptySide: () {
                      sideWidget.value = null;
                      sideType.value = null;
                    },
                  ),
                  const Divider(),
                  ChannelDetails(
                    channelId: videoData.uploaderId!.value,
                    isOnVideo: true,
                  ),
                  const Divider(height: 4),
                  ListTile(
                    onTap: commentsSnapshot.data == null
                        ? null
                        : sideType.value == SideType.comment
                            ? emptySide
                            : () {
                                sideType.value = SideType.comment;
                                sideWidget.value = CommentsWidget(
                                  onClose: emptySide,
                                  replyComment: replyComment,
                                  snapshot: commentsSnapshot,
                                  videoId: videoData.id.value,
                                );
                              },
                    enabled: commentsSnapshot.data != null,
                    title: Text(
                      context.locals.comments,
                    ),
                  ),
                  const Divider(
                    height: 4,
                  ),
                  if (context.isMobile)
                    DescriptionWidget(
                      video: videoData,
                    ),
                ],
              ),
              if (context.isMobile) ...[
                if (sideWidget.value != null) sideWidget.value!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

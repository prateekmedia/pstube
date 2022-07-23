import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/data/enums/enums.dart';
import 'package:pstube/data/models/video_data.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/screens/video_screen/src/export.dart';
import 'package:pstube/ui/screens/video_screen/view_model/comments_view_model.dart';
import 'package:pstube/ui/widgets/channel_details.dart';

class VideoWidget extends ConsumerWidget {
  const VideoWidget({
    super.key,
    required this.videoData,
    required this.sideType,
    required this.sideWidget,
    required this.emptySide,
    required this.isCinemaMode,
  });

  final ValueNotifier<bool> isCinemaMode;
  final VideoData videoData;
  final ValueNotifier<SideType?> sideType;
  final ValueNotifier<Widget?> sideWidget;
  final VoidCallback emptySide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsP = ref.watch(commentsProvider);
    final comments = commentsP.comments;

    return Column(
      children: [
        if (videoData.videoStreams != null)
          PlatformVideoPlayer(
            isCinemaMode: isCinemaMode,
            videoData: videoData,
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              height: context.isMobile ? 320 : 480,
              width: context.isMobile ? 569 : 853,
            ),
            child: Stack(
              children: [
                Container(
                  constraints: BoxConstraints.tightFor(
                    height: context.isMobile ? 320 : 480,
                    width: context.isMobile ? 569 : 853,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: videoData.thumbnails.mediumResUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                ColoredBox(
                  color: Colors.black.withOpacity(0.25),
                ),
                const Align(
                  child: CircularProgressIndicator(),
                ),
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
                    child: Text(
                      videoData.title!,
                      style: context.textTheme.headline4!.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  VideoActions(
                    videoData: videoData,
                    sideType: sideType,
                    isCinemaMode: isCinemaMode,
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
                    onTap: comments == null
                        ? null
                        : sideType.value == SideType.comment
                            ? emptySide
                            : () {
                                sideType.value = SideType.comment;
                                sideWidget.value = CommentsWidget(
                                  onClose: emptySide,
                                  videoId: videoData.id.value,
                                );
                              },
                    enabled: comments != null,
                    title: Text(
                      context.locals.comments,
                    ),
                  ),
                  const Divider(
                    height: 4,
                  ),
                  if (context.isMobile ||
                      sideType.value != null ||
                      isCinemaMode.value)
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

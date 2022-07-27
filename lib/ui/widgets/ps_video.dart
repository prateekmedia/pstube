import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/foundation/services.dart';
import 'package:pstube/foundation/services/piped_service.dart';
import 'package:pstube/ui/screens/screens.dart';
import 'package:pstube/ui/widgets/custom_pip_view.dart';
import 'package:pstube/ui/widgets/widgets.dart';

class PSVideo extends ConsumerWidget {
  const PSVideo({
    super.key,
    this.videoUrl,
    this.date,
    this.views,
    this.duration,
    this.videoData,
    this.isRow = false,
    this.showChannel = true,
    this.loadData = false,
    this.actions = const [],
    this.isRelated = false,
    this.onTap,
    this.isInsidePopup = false,
    this.isClickable = true,
  });

  final String? date;
  final String? views;
  final String? duration;
  final String? videoUrl;
  final VideoData? videoData;
  final bool loadData;
  final bool isRow;
  final bool showChannel;
  final List<Widget> actions;
  final bool isRelated;
  final VoidCallback? onTap;
  final bool isInsidePopup;
  final bool isClickable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<VideoData?>(
      future: videoUrl != null
          ? ref.watch(pipedServiceProvider).getVideoData(VideoId(videoUrl!))
          : null,
      builder: (context, snapshot) {
        final video = snapshot.data ?? videoData;

        return Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            onTap: onTap ??
                (video != null && isClickable
                    ? () => CustomPIPView.of(context)!.presentTop(
                          VideoScreen(
                            video: video,
                            loadData: isRelated || loadData,
                          ),
                        )
                    : null),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isRow
                  ? Row(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                height: context.isMobile ? 73 : 90,
                                width: context.isMobile ? 130 : 160,
                                child: getThumbnail(video, context),
                              ),
                            ),
                            if (video != null)
                              Positioned.fill(
                                child: Align(
                                  alignment: const Alignment(0.90, 0.90),
                                  child: getDuration(video),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(child: getTitle(video)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (showChannel)
                                Row(
                                  children: [
                                    Flexible(
                                      child: getAuthor(video, context),
                                    ),
                                  ],
                                ),
                              buildColumnOrRow(
                                isRow: !context.isMobile,
                                children: [
                                  Flexible(
                                    child: getViews(video, context),
                                  ),
                                  if (!isRelated)
                                    Flexible(
                                      child: getTime(video),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                        if (!isInsidePopup) ...[
                          getDownloadButton(video, context),
                        ],
                        ...actions.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: e,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            children: [
                              getThumbnail(video, context),
                              if (video != null)
                                Positioned.fill(
                                  child: Align(
                                    alignment: const Alignment(0.98, 0.94),
                                    child: getDuration(video),
                                  ),
                                )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (video != null)
                                    getTitle(video)
                                  else
                                    Container(),
                                  if (showChannel) getAuthor(video, context),
                                ],
                              ),
                            ),
                            // if (!isInsideDownloadPopup) ...[
                            getDownloadButton(video, context),
                            // ],
                            ...actions.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: e,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            getViews(video, context),
                            if (!isRelated)
                              Flexible(
                                child: getTime(video),
                              ),
                          ],
                        )
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  AspectRatio getThumbnail(VideoData? video, BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: video != null
          ? DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                    video.thumbnails.mediumResUrl,
                  ),
                ),
              ),
            )
          : Row(
              children: [
                Flexible(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.getBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  IconWithLabel getDuration(VideoData video) => IconWithLabel(
        label: duration ?? Duration(seconds: video.duration ?? 0).format(),
        secColor: SecColor.dark,
      );

  Text getTitle(VideoData? video) => Text(
        video != null && video.title != null ? video.title! : '           ',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      );

  GestureDetector getAuthor(VideoData? video, BuildContext context) =>
      GestureDetector(
        onTap: video != null && video.uploaderId != null
            ? () => context.pushPage(
                  ChannelScreen(
                    channelId: video.uploaderId!.value,
                  ),
                )
            : null,
        child: IconWithLabel(
          label: video != null && video.uploader != null
              ? video.uploader!
              : '                ',
          secColor: SecColor.dark,
        ),
      );

  AdwButton getDownloadButton(VideoData? video, BuildContext context) =>
      AdwButton.circular(
        onPressed: video != null
            ? () => showDownloadPopup(
                  context,
                  isClickable: true,
                  video: video,
                )
            : null,
        size: 36,
        child: Icon(
          LucideIcons.download,
          size: 20,
          color: video == null ? Colors.transparent : null,
        ),
      );

  IconWithLabel getViews(VideoData? video, BuildContext context) {
    return IconWithLabel(
      label: views ??
          (video != null
              ? '${(video.views ?? 0).formatNumber} ${context.locals.views}'
              : '           '),
    );
  }

  IconWithLabel getTime(VideoData? video) => IconWithLabel(
        label: video != null && video.uploadDate != null
            ? video.uploadDate!
            : '           ',
      );
}

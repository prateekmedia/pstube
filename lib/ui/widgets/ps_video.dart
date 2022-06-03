import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pstube/data/extensions/extensions.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/data/services/services.dart';
import 'package:pstube/ui/screens/screens.dart';
import 'package:pstube/ui/widgets/widgets.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PSVideo extends HookWidget {
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
  }) : isRelated = false;

  PSVideo.related({
    super.key,
    required RelatedVideo relatedVideo,
  })  : actions = [],
        date = null,
        showChannel = true,
        loadData = false,
        isRow = false,
        isRelated = true,
        videoUrl = null,
        duration = relatedVideo.duration,
        views = relatedVideo.views,
        videoData = Video(
          VideoId(relatedVideo.url),
          relatedVideo.title,
          relatedVideo.uploader,
          ChannelId(relatedVideo.channelUrl),
          DateTime.now(),
          DateTime.now(),
          '',
          Duration.zero,
          ThumbnailSet(
            relatedVideo.url.replaceAll(
              '${Constants.ytCom}/watch?v=',
              '',
            ),
          ),
          [''],
          const Engagement(0, 0, 0),
          false,
        );

  final String? date;
  final String? views;
  final String? duration;
  final String? videoUrl;
  final Video? videoData;
  final bool loadData;
  final bool isRow;
  final bool showChannel;
  final List<Widget> actions;
  final bool isRelated;

  @override
  Widget build(BuildContext context) {
    final yt = YoutubeExplode();
    Future<Video?> getVideo() => yt.videos.get(videoUrl);

    return FutureBuilder<Video?>(
      future: videoUrl != null ? getVideo().whenComplete(yt.close) : null,
      builder: (context, snapshot) {
        final video = snapshot.data ?? videoData;
        return Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            onTap: video != null
                ? () => context.pushPage(
                      VideoScreen(
                        video: video,
                        loadData: isRelated || loadData,
                      ),
                    )
                : null,
            child: Padding(
              padding:
                  // isInsideDownloadPopup
                  //     ? EdgeInsets.zero :
                  const EdgeInsets.all(16),
              child: isRow
                  ? Row(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                height: 90,
                                width: 160,
                                child:
                                    getThumbnail(video, context, isRow: isRow),
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
                    )
                  : Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            children: [
                              getThumbnail(video, context, isRow: isRow),
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
                            if (!isRelated) getTime(video),
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

  AspectRatio getThumbnail(
    Video? video,
    BuildContext context, {
    required bool isRow,
  }) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: video != null
          ? DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                    isRow
                        ? video.thumbnails.lowResUrl
                        : video.thumbnails.mediumResUrl,
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

  IconWithLabel getDuration(Video video) => IconWithLabel(
        label: duration ?? (video.duration ?? Duration.zero).format(),
        secColor: SecColor.dark,
      );

  Text getTitle(Video? video) => Text(
        video != null ? video.title : '           ',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      );

  GestureDetector getAuthor(Video? video, BuildContext context) =>
      GestureDetector(
        onTap: (video != null)
            ? () => context.pushPage(ChannelScreen(id: video.channelId.value))
            : null,
        child: IconWithLabel(
          label: video != null ? video.author : '                ',
          secColor: SecColor.dark,
        ),
      );

  AdwButton getDownloadButton(Video? video, BuildContext context) =>
      AdwButton.circular(
        onPressed: video != null
            ? () => showDownloadPopup(context, video: video)
            : null,
        size: 36,
        child: Icon(
          LucideIcons.download,
          size: 20,
          color: video == null ? Colors.transparent : null,
        ),
      );

  IconWithLabel getViews(Video? video, BuildContext context) {
    return IconWithLabel(
      label: views ??
          (video != null
              ? '${video.engagement.viewCount.formatNumber} ${context.locals.views}'
              : '           '),
    );
  }

  IconWithLabel getTime(Video? video) => IconWithLabel(
        label: video != null
            ? date ?? timeago.format(video.uploadDate ?? DateTime.now())
            : '           ',
      );
}

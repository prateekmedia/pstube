import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:pstube/screens/screens.dart';
import 'package:pstube/utils/utils.dart';
import 'package:pstube/widgets/widgets.dart';

import 'package:timeago/timeago.dart' as timeago;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SFVideo extends HookWidget {
  const SFVideo({
    Key? key,
    this.videoUrl,
    this.date,
    this.videoData,
    this.isRow = false,
    this.showChannel = true,
    this.isInsideDownloadPopup = false,
    this.loadData = false,
    this.actions = const [],
  }) : super(key: key);

  final String? date;
  final String? videoUrl;
  final Video? videoData;
  final bool loadData;
  final bool isRow;
  final bool isInsideDownloadPopup;
  final bool showChannel;
  final List<Widget> actions;

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
                        loadData: loadData,
                      ),
                    )
                : null,
            child: Padding(
              padding: isInsideDownloadPopup
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(16),
              child: isRow
                  ? Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.all(5),
                              child: getThumbnail(video, context, isRow: isRow),
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
                        const SizedBox(width: 6),
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
                                isRow: showChannel && !context.isMobile,
                                children: [
                                  Flexible(
                                    child: getViews(video, context),
                                  ),
                                  Flexible(
                                    child: getTime(video),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        if (!isInsideDownloadPopup) ...[
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
                        Stack(
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
                            if (!isInsideDownloadPopup) ...[
                              getDownloadButton(video, context),
                            ],
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
                            getTime(video),
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
          ? Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fitWidth,
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
                  child: Container(
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
        label: (video.duration ?? Duration.zero).format(),
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
      label: video != null
          ? '${video.engagement.viewCount.formatNumber} ${context.locals.views}'
          : '           ',
    );
  }

  IconWithLabel getTime(Video? video) => IconWithLabel(
        label: video != null
            ? date ?? timeago.format(video.uploadDate ?? DateTime.now())
            : '           ',
      );
}

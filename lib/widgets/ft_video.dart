import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class FTVideo extends StatelessWidget {
  const FTVideo({
    Key? key,
    this.videoUrl,
    this.videoData,
    this.isRow = false,
    this.showChannel = true,
    this.isInsideDownloadPopup = false,
    this.loadData = false,
    this.actions = const [],
  }) : super(key: key);

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
        return Container(
          padding:
              isInsideDownloadPopup ? EdgeInsets.zero : const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          color: context.theme.cardColor.withOpacity(0.65),
          child: GestureDetector(
            onTap: video != null
                ? () => context.pushPage(
                      VideoScreen(
                        video: video,
                        loadData: loadData,
                      ),
                    )
                : null,
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
                            child: getThumbnail(video, context),
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
                            Row(
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
                      ...actions,
                    ],
                  )
                : Column(
                    children: [
                      Stack(
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
                          ...actions,
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
        );
      },
    );
  }

  AspectRatio getThumbnail(Video? video, BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: video != null
          ? Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: CachedNetworkImageProvider(video.thumbnails.lowResUrl),
                ),
              ),
            )
          : Row(
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.getAltBackgroundColor,
                          context.getBackgroundColor
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  IconWithLabel getDuration(Video video) {
    return IconWithLabel(
      label: (video.duration ?? Duration.zero).format(),
      secColor: SecColor.dark,
    );
  }

  Text getTitle(Video? video) {
    return Text(
      video != null ? video.title : '           ',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 14),
    );
  }

  GestureDetector getAuthor(Video? video, BuildContext context) {
    return GestureDetector(
      onTap: (video != null)
          ? () => context.pushPage(ChannelScreen(id: video.channelId.value))
          : null,
      child: IconWithLabel(
        label: video != null ? video.author : '                ',
        secColor: SecColor.dark,
      ),
    );
  }

  AdwButton getDownloadButton(Video? video, BuildContext context) {
    return AdwButton.circular(
      onPressed:
          video != null ? () => showDownloadPopup(context, video: video) : null,
      child: const Icon(Icons.download),
    );
  }

  IconWithLabel getViews(Video? video, BuildContext context) {
    return IconWithLabel(
      label: video != null
          ? '${video.engagement.viewCount.formatNumber} ${context.locals.views}'
          : '           ',
    );
  }

  IconWithLabel getTime(Video? video) {
    return IconWithLabel(
      label: video != null
          ? timeago.format(video.uploadDate ?? DateTime.now())
          : '           ',
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';

class FTVideo extends StatelessWidget {
  final String? videoUrl;
  final Video? videoData;
  final bool loadData;
  final bool isRow;
  final bool isInsideDownloadPopup;
  final bool showChannel;
  final List<Widget> actions;

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

  @override
  Widget build(BuildContext context) {
    final yt = YoutubeExplode();
    Future<Video?> getVideo() => yt.videos.get(videoUrl!);

    return FutureBuilder<Video?>(
        future: videoUrl != null ? getVideo().whenComplete(() => yt.close()) : null,
        builder: (context, snapshot) {
          final Video? video = snapshot.data ?? videoData;
          return Container(
            padding: isInsideDownloadPopup ? EdgeInsets.zero : const EdgeInsets.all(16),
            width: context.width,
            child: isRow
                ? GestureDetector(
                    onTap: video != null
                        ? () => context.pushPage(VideoScreen(
                              video: video,
                              loadData: loadData,
                            ))
                        : null,
                    child: Row(children: [
                      Stack(
                        children: [
                          Container(
                            height: 90,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.all(5),
                            child: AspectRatio(
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
                                                  colors: [context.getAltBackgroundColor, context.getBackgroundColor]),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          if (video != null)
                            Positioned.fill(
                              child: Align(
                                alignment: const Alignment(0.90, 0.90),
                                child: IconWithLabel(
                                    label: (video.duration ?? const Duration(seconds: 0)).format(),
                                    secColor: SecColor.dark),
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
                                Flexible(
                                  child: Text(
                                    video != null ? video.title : "...",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (showChannel)
                              Row(
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: (video != null)
                                          ? () => context.pushPage(ChannelScreen(id: video.channelId.value))
                                          : null,
                                      child: IconWithLabel(
                                        label: video != null ? video.author : "Loading...",
                                        secColor: SecColor.dark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            Row(
                              children: [
                                Flexible(
                                  child: IconWithLabel(
                                    label: (video != null ? video.engagement.viewCount.formatNumber : "0") + " views",
                                  ),
                                ),
                                Flexible(
                                  child: IconWithLabel(
                                    label:
                                        video != null ? timeago.format(video.uploadDate ?? DateTime.now()) : "just now",
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      if (!isInsideDownloadPopup) ...[
                        IconButton(
                          onPressed: video != null ? () => showDownloadPopup(context, video: video) : null,
                          icon: const FaIcon(FontAwesomeIcons.download),
                        ),
                      ],
                      ...actions,
                    ]),
                  )
                : Column(
                    children: [
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: video != null
                                ? GestureDetector(
                                    onTap: () => context.pushPage(VideoScreen(video: video, loadData: loadData)),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          fit: BoxFit.contain,
                                          image: CachedNetworkImageProvider(
                                            video.thumbnails.mediumResUrl,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Flexible(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: [context.getAltBackgroundColor, context.getBackgroundColor]),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          if (video != null)
                            Positioned.fill(
                              child: Align(
                                alignment: const Alignment(0.98, 0.94),
                                child: IconWithLabel(
                                    label: (video.duration ?? const Duration(seconds: 0)).format(),
                                    secColor: SecColor.dark),
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
                                video != null
                                    ? Text(
                                        video.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 15),
                                      )
                                    : Container(),
                                if (showChannel)
                                  GestureDetector(
                                    onTap: (video != null)
                                        ? () => context.pushPage(ChannelScreen(id: video.channelId.value))
                                        : null,
                                    child: IconWithLabel(
                                      label: video != null ? video.author : "Loading...",
                                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                                      secColor: SecColor.dark,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (!isInsideDownloadPopup) ...[
                            IconButton(
                              onPressed: video != null ? () => showDownloadPopup(context, video: video) : null,
                              icon: const FaIcon(FontAwesomeIcons.download),
                            ),
                          ],
                          ...actions,
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconWithLabel(
                            label: (video != null ? video.engagement.viewCount.formatNumber : "0") + " views",
                          ),
                          IconWithLabel(
                            label: video != null ? timeago.format(video.uploadDate ?? DateTime.now()) : "just now",
                          ),
                        ],
                      )
                    ],
                  ),
          );
        });
  }
}

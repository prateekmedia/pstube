import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shimmer/shimmer.dart';

import 'widgets.dart';
import '../utils/utils.dart';

class FTVideo extends HookWidget {
  final String videoUrl;
  final bool isRow;

  const FTVideo({Key? key, required this.videoUrl, this.isRow = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final snapshot =
        useFuture(useMemoized(() => YoutubeExplode().videos.get(videoUrl)));
    Video? video = snapshot.data;
    return Container(
      padding: const EdgeInsets.all(16),
      width: context.width,
      child: isRow
          ? Row(children: [
              SizedBox(
                height: 70,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: video != null
                      ? Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: CachedNetworkImageProvider(
                                  video.thumbnails.lowResUrl),
                            ),
                          ),
                        )
                      : Shimmer.fromColors(
                          baseColor: Colors.grey[900]!,
                          highlightColor: Colors.grey[800]!,
                          child: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconWithLabel(video == null ? "Loading" : video.title,
                      style:
                          context.textTheme.bodyText2!.copyWith(fontSize: 12)),
                  if (video != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(video.author,
                          style: context.textTheme.bodyText2!
                              .copyWith(fontSize: 12)),
                    ),
                ],
              )
            ])
          : Column(
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: video != null
                          ? GestureDetector(
                              onTap: () =>
                                  context.pushPage(VideoScreen(video: video)),
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
                          : Shimmer.fromColors(
                              baseColor: Colors.grey[900]!,
                              highlightColor: Colors.grey[800]!,
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
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
                          alignment: const Alignment(0.98, 0.94),
                          child: iconWithLabel(
                              (video.duration ?? const Duration(seconds: 0))
                                  .format(),
                              secColor: SecColor.dark),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: video != null
                          ? Text(
                              video.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 18),
                            )
                          : Container(),
                    ),
                    IconButton(
                      onPressed: video != null
                          ? () => showDownloadPopup(context, video)
                          : null,
                      icon: const Icon(Icons.save_alt_outlined),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: (video != null)
                                ? () => context.pushPage(
                                    ChannelScreen(id: video.channelId.value))
                                : null,
                            child: iconWithLabel(
                              video != null ? video.author : "Loading...",
                              secColor: SecColor.dark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    iconWithLabel(
                      (video != null
                              ? video.engagement.viewCount.formatNumber
                              : "0") +
                          " views",
                    ),
                    iconWithLabel(
                      video != null
                          ? timeago.format(video.uploadDate ?? DateTime.now())
                          : "just now",
                    ),
                  ],
                )
              ],
            ),
    );
  }
}

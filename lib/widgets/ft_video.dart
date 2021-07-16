import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
      padding: EdgeInsets.all(16),
      width: context.width,
      child: isRow
          ? Row(children: [
              Container(
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
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  secLabel(video == null ? "Loading" : video.title,
                      enabled: video == null,
                      style:
                          context.textTheme.bodyText2!.copyWith(fontSize: 12)),
                  if (video != null)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 14),
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
                          alignment: Alignment(0.98, 0.94),
                          child: secLabel(
                              (video.duration ?? Duration(seconds: 0)).format(),
                              secColor: SecColor.dark),
                        ),
                      )
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: video != null
                          ? Text(
                              video.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 18),
                            )
                          : Container(),
                    ),
                    IconButton(
                      onPressed: video != null
                          ? () {
                              showPopover(context, builder: (ctx) {
                                return FittedBox();
                              });
                            }
                          : null,
                      icon: Icon(
                        MdiIcons.progressDownload,
                      ),
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
                            child: secLabel(
                              video != null ? video.author : "Loading...",
                              secColor: SecColor.dark,
                              enabled: video == null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    secLabel(
                      (video != null
                              ? video.engagement.viewCount.formatNumber
                              : "0") +
                          " views",
                      enabled: video == null,
                    ),
                    secLabel(
                      video != null
                          ? timeago.format(video.uploadDate ?? DateTime.now())
                          : "just now",
                      enabled: video == null,
                    ),
                  ],
                )
              ],
            ),
    );
  }
}

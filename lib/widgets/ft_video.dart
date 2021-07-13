import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutube/screens/channel_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'widgets.dart';
import '../utils/utils.dart';

class FTVideo extends StatelessWidget {
  final String videoUrl;
  final bool isRow;

  const FTVideo({Key? key, required this.videoUrl, this.isRow = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Video>(
        future: YoutubeExplode().videos.get(videoUrl),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            Video video = snapshot.data!;
            return Container(
              padding: EdgeInsets.all(16),
              width: context.width,
              child: buildColumnOrRow(
                isRow,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
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
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment(0.98, 0.94),
                          child: secLabel(
                              label: (video.duration ?? Duration(seconds: 0))
                                  .format(),
                              secColor: SecColor.dark),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showPopover(context, builder: (ctx) {
                            return Container();
                          });
                        },
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
                              onTap: () => context.pushPage(
                                  ChannelScreen(id: video.channelId.value)),
                              child: secLabel(
                                secColor: SecColor.dark,
                                label: video.author,
                              ),
                            ),
                          ],
                        ),
                      ),
                      secLabel(
                        label:
                            video.engagement.viewCount.formatNumber + " views",
                      ),
                      secLabel(
                        label:
                            timeago.format(video.uploadDate ?? DateTime.now()),
                      ),
                    ],
                  )
                ],
              ),
            );
          } else {
            return CircularProgressIndicator().center();
          }
        });
  }
}

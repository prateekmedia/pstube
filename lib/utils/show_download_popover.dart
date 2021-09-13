import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutube/models/models.dart';
import 'package:flutube/providers/providers.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'utils.dart';

Future showDownloadPopup(BuildContext context, Video video) {
  return showPopover(
    context: context,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    builder: (ctx) => DownloadsWidget(video: video),
  );
}

class DownloadsWidget extends ConsumerWidget {
  final Video video;
  final VoidCallback? onClose;

  const DownloadsWidget({
    Key? key,
    required this.video,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(context, ref) {
    return FutureBuilder<StreamManifest>(
      future: YoutubeExplode().videos.streamsClient.getManifest(video.id.value),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ref.watch(thumbnailDownloaderProvider)) ...[
                    linksHeader(
                      icon: Icons.image,
                      label: "Thumbnail",
                      padding: const EdgeInsets.only(top: 6, bottom: 14),
                    ),
                    for (var thumbnail in video.thumbnails.toStreamInfo)
                      CustomListTile(
                        stream: thumbnail,
                        video: video,
                        onClose: onClose,
                      ),
                  ],
                  linksHeader(
                    icon: Icons.perm_media,
                    label: "Video + Audio",
                    padding: const EdgeInsets.only(top: 6, bottom: 14),
                  ),
                  for (var videoStream in snapshot.data!.muxed.toList().sortByVideoQuality())
                    CustomListTile(
                      stream: videoStream,
                      video: video,
                      onClose: onClose,
                    ),
                  linksHeader(
                    icon: Ionicons.musical_note,
                    label: "Audio only",
                  ),
                  for (var audioStream in snapshot.data!.audioOnly.toList().reversed)
                    CustomListTile(
                      stream: audioStream,
                      video: video,
                      onClose: onClose,
                    ),
                  linksHeader(
                    icon: Ionicons.videocam,
                    label: "Video only",
                  ),
                  for (var videoStream in snapshot.data!.videoOnly.toList().sortByVideoQuality())
                    CustomListTile(
                      stream: videoStream,
                      video: video,
                      onClose: onClose,
                    ),
                ],
              )
            : SizedBox(
                height: 100,
                child: getCircularProgressIndicator(),
              );
      },
    );
  }
}

Widget linksHeader(
    {required IconData icon, required String label, EdgeInsets padding = const EdgeInsets.symmetric(vertical: 14)}) {
  return Padding(
    padding: padding,
    child: Row(
      children: [
        Icon(
          icon,
          size: 22,
        ),
        const SizedBox(width: 10),
        Text(label)
      ],
    ),
  );
}

class CustomListTile extends ConsumerWidget {
  final dynamic stream;
  final Video video;
  final VoidCallback? onClose;

  const CustomListTile({
    Key? key,
    required this.stream,
    required this.video,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () async {
          if ((Platform.isAndroid || Platform.isIOS) && !await Permission.storage.request().isGranted) return;
          ref.watch(downloadListProvider.notifier).addDownload(
                DownloadItem.fromVideo(
                  video: video,
                  stream: stream,
                  path: ref.watch(downloadPathProvider).path,
                ),
              );
          onClose != null ? onClose!() : context.back();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (stream is ThumbnailStreamInfo
                            ? stream.containerName
                            : stream is AudioOnlyStreamInfo
                                ? stream.audioCodec.split('.')[0].replaceAll('mp4a', 'm4a')
                                : stream.container.name)
                        .toUpperCase(),
                  ),
                  Text(stream is ThumbnailStreamInfo ? "" : (stream.size.totalBytes as int).getFileSize()),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  stream is VideoStreamInfo
                      ? stream.videoQualityLabel
                      : stream is AudioOnlyStreamInfo
                          ? (stream.bitrate.bitsPerSecond as int).getBitrate()
                          : stream is ThumbnailStreamInfo
                              ? stream.name
                              : "",
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

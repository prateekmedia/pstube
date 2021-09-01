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
    builder: (ctx) => FutureBuilder<StreamManifest>(
      future: YoutubeExplode().videos.streamsClient.getManifest(video.id.value),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  linksHeader(
                    icon: Icons.perm_media,
                    label: "Video + Audio",
                    padding: const EdgeInsets.only(top: 6, bottom: 14),
                  ),
                  for (var videoStream
                      in snapshot.data!.muxed.toList().sortByVideoQuality())
                    CustomListTile(
                      stream: videoStream,
                      video: video,
                    ),
                  linksHeader(
                    icon: Ionicons.musical_note,
                    label: "Audio only",
                  ),
                  for (var audioStream
                      in snapshot.data!.audioOnly.toList().reversed)
                    CustomListTile(
                      stream: audioStream,
                      video: video,
                    ),
                  linksHeader(
                    icon: Ionicons.videocam,
                    label: "Video only",
                  ),
                  for (var videoStream
                      in snapshot.data!.videoOnly.toList().sortByVideoQuality())
                    CustomListTile(
                      stream: videoStream,
                      video: video,
                    ),
                ],
              )
            : const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
      },
    ),
  );
}

Widget linksHeader(
    {required IconData icon,
    required String label,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 14)}) {
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

  const CustomListTile({
    Key? key,
    required this.stream,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () async {
          if ((Platform.isAndroid || Platform.isIOS) &&
              !await Permission.storage.request().isGranted) return;
          ref.watch(downloadListProvider.notifier).addDownload(
                DownloadItem.fromVideo(
                  video: video,
                  stream: stream,
                  path: ref.watch(downloadPathProvider).path,
                ),
              );
          context.back();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (stream is AudioOnlyStreamInfo
                            ? stream.audioCodec
                                .split('.')[0]
                                .replaceAll('mp4a', 'm4a')
                            : stream.container.name)
                        .toUpperCase(),
                  ),
                  Text((stream.size.totalBytes as int).getFileSize()),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  stream is VideoStreamInfo
                      ? stream.videoQualityLabel
                      : stream is AudioOnlyStreamInfo
                          ? (stream.bitrate.bitsPerSecond as int).getBitrate()
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

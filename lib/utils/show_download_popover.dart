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
    builder: (ctx) => FutureBuilder<StreamManifest>(
      future: YoutubeExplode().videos.streamsClient.getManifest(video.id.value),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),
                  linksHeader(icon: Ionicons.musical_note, label: "Audio"),
                  const SizedBox(height: 14),
                  for (var audioStream
                      in snapshot.data!.audioOnly.toList().reversed)
                    CustomListTile(
                      stream: audioStream,
                      video: video,
                    ),
                  const SizedBox(height: 14),
                  linksHeader(icon: Ionicons.videocam, label: "Video"),
                  const SizedBox(height: 14),
                  for (var videoStream
                      in snapshot.data!.video.toList().sortByVideoQuality())
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

Widget linksHeader({required IconData icon, required String label}) {
  return Row(
    children: [
      Icon(
        icon,
        size: 22,
      ),
      const SizedBox(width: 10),
      Text("$label Download Links")
    ],
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
                  Text(stream is AudioOnlyStreamInfo
                      ? "M4A"
                      : stream.container.name.toUpperCase()),
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

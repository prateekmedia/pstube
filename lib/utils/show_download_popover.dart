import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutube/providers/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'utils.dart';

Future showDownloadPopup(BuildContext context, Video video) {
  return showBarModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Material(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder<StreamManifest>(
                future: YoutubeExplode()
                    .videos
                    .streamsClient
                    .getManifest(video.id.value),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 6),
                            linksHeader(
                                icon: Ionicons.musical_note, label: "Audio"),
                            const SizedBox(height: 14),
                            for (var audioStream
                                in snapshot.data!.audioOnly.toList().reversed)
                              CustomListTile(
                                stream: audioStream,
                                vidName: video.title,
                              ),
                            const SizedBox(height: 14),
                            linksHeader(
                                icon: Ionicons.videocam, label: "Video"),
                            const SizedBox(height: 14),
                            for (var videoStream in snapshot.data!.video
                                .where((element) => element.tag < 100)
                                .toList()
                                .sortByVideoQuality())
                              CustomListTile(
                                stream: videoStream,
                                vidName: video.title,
                              ),
                          ],
                        )
                      : const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                }),
          ),
        );
      });
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
  final String vidName;

  const CustomListTile({
    Key? key,
    required this.stream,
    required this.vidName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final String path = ref.read(downloadPathProvider).path;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () async => Dio().downloadUri(
            stream.url,
            path +
                vidName +
                '(' +
                (stream is AudioOnlyStreamInfo
                    ? stream.audioCodec.split('.')[0].toUpperCase()
                    : '${stream.videoResolution.width}x${stream.videoResolution.height}') +
                (stream is MuxedStreamInfo ? '.mp4' : '.m4a'),
            onReceiveProgress: (downloaded, total) =>
                debugPrint((downloaded / total).toString())),
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
                          ? stream.bitrate.bitsPerSecond.getBitrate()
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

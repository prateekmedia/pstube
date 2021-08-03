import 'package:flutter/material.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:ionicons/ionicons.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'utils.dart';

Future showDownloadPopup(BuildContext context, Video video) {
  return showPopover(context, builder: (ctx) {
    return FutureBuilder<StreamManifest>(
        future:
            YoutubeExplode().videos.streamsClient.getManifest(video.id.value),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Column(
                  children: [
                    const SizedBox(height: 6),
                    linksHeader(icon: Ionicons.musical_note, label: "Audio"),
                    const SizedBox(height: 14),
                    for (var audioStream in snapshot.data!.audioOnly.toList())
                      customListTile(audioStream),
                    const SizedBox(height: 14),
                    linksHeader(icon: Ionicons.videocam, label: "Video"),
                    const SizedBox(height: 14),
                    for (var videoStream in snapshot.data!.video
                        .where((element) => element.tag > 100)
                        .toList())
                      customListTile(videoStream),
                  ],
                )
              : const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
        });
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

Widget customListTile(dynamic stream) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: InkWell(
      onTap: () => debugPrint("It's so cold outside!"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(stream is AudioOnlyStreamInfo
                    ? stream.audioCodec.split('.')[0].toUpperCase()
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

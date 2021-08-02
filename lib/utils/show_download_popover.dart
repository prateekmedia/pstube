import 'package:flutter/material.dart';
import 'package:flutube/widgets/widgets.dart';
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
                    Row(
                      children: const [
                        Icon(Icons.audiotrack),
                        SizedBox(width: 15),
                        Text("Audio Download Links")
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (var audioStream in snapshot.data!.audioOnly.toList())
                      customListTile(audioStream),
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Icon(Icons.video_library),
                        SizedBox(width: 15),
                        Text("Video Download Links")
                      ],
                    ),
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

Container customListTile(dynamic stream) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: InkWell(
      onTap: () => debugPrint("It's so cold outside!"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            Text(stream.container.name.toUpperCase()),
            Expanded(
              child: Column(
                children: [
                  Text(
                    stream is VideoStreamInfo
                        ? stream.videoQualityLabel
                        : stream is AudioOnlyStreamInfo
                            ? stream.bitrate.bitsPerSecond.getBitrate()
                            : "",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Text((stream.size.totalBytes as int).getFileSize()),
          ],
        ),
      ),
    ),
  );
}

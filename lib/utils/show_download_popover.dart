import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sftube/models/models.dart';
import 'package:sftube/providers/providers.dart';
import 'package:sftube/utils/utils.dart';
import 'package:sftube/widgets/widgets.dart';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final Widget _progressIndicator = SizedBox(
  height: 100,
  child: getCircularProgressIndicator(),
);

Future showDownloadPopup(
  BuildContext context, {
  Video? video,
  String? videoUrl,
}) {
  assert(
    video != null || videoUrl != null,
    "Both video and videoUrl can't be null",
  );
  final yt = YoutubeExplode();
  Future<Video?> getVideo() => yt.videos.get(videoUrl);
  return showPopover<dynamic>(
    context: context,
    title: context.locals.download,
    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
    builder: (ctx) => FutureBuilder<Video?>(
      future: videoUrl != null ? getVideo().whenComplete(yt.close) : null,
      builder: (context, snapshot) {
        return video != null || snapshot.hasData && snapshot.data != null
            ? DownloadsWidget(video: video ?? snapshot.data!)
            : snapshot.hasError
                ? Text(context.locals.error)
                : _progressIndicator;
      },
    ),
  );
}

class DownloadsWidget extends ConsumerWidget {
  const DownloadsWidget({
    Key? key,
    required this.video,
    this.onClose,
  }) : super(key: key);

  final Video video;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: FutureBuilder<StreamManifest>(
        future:
            YoutubeExplode().videos.streamsClient.getManifest(video.id.value),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ref.watch(thumbnailDownloaderProvider)) ...[
                      linksHeader(
                        context,
                        icon: Icons.video_call,
                        label: context.locals.thumbnail,
                        padding: const EdgeInsets.only(top: 6, bottom: 14),
                      ),
                      for (var thumbnail
                          in video.thumbnails.toStreamInfo(context))
                        CustomListTile(
                          stream: thumbnail,
                          video: video,
                          onClose: onClose,
                        ),
                    ],
                    linksHeader(
                      context,
                      icon: Icons.movie,
                      label: context.locals.videoPlusAudio,
                      padding: const EdgeInsets.only(top: 6, bottom: 14),
                    ),
                    for (var videoStream
                        in snapshot.data!.muxed.sortByVideoQuality())
                      CustomListTile(
                        stream: videoStream,
                        video: video,
                        onClose: onClose,
                      ),
                    linksHeader(
                      context,
                      icon: Icons.audiotrack,
                      label: context.locals.audioOnly,
                    ),
                    for (var audioStream in snapshot.data!.audioOnly.reversed)
                      CustomListTile(
                        stream: audioStream,
                        video: video,
                        onClose: onClose,
                      ),
                    linksHeader(
                      context,
                      icon: Icons.videocam,
                      label: context.locals.videoOnly,
                    ),
                    for (var videoStream in snapshot.data!.videoOnly
                        .where((element) => element.tag < 200))
                      CustomListTile(
                        stream: videoStream,
                        video: video,
                        onClose: onClose,
                      ),
                  ],
                )
              : _progressIndicator;
        },
      ),
    );
  }
}

Widget linksHeader(
  BuildContext context, {
  required IconData icon,
  required String label,
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 14),
}) {
  return Padding(
    padding: padding,
    child: Row(
      children: [
        Icon(
          icon,
          size: 22,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: context.textTheme.headline5,
        )
      ],
    ),
  );
}

class CustomListTile extends ConsumerStatefulWidget {
  const CustomListTile({
    Key? key,
    required this.stream,
    required this.video,
    this.onClose,
  }) : super(key: key);

  final dynamic stream;
  final Video video;
  final VoidCallback? onClose;

  @override
  ConsumerState<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends ConsumerState<CustomListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () async {
          if ((Platform.isAndroid || Platform.isIOS) &&
              !await Permission.storage.request().isGranted) return;
          if (!mounted) return;
          widget.onClose != null ? widget.onClose!() : context.back();
          await ref.watch(downloadListProvider.notifier).addDownload(
                context,
                DownloadItem.fromVideo(
                  video: widget.video,
                  stream: widget.stream,
                  path: ref.watch(downloadPathProvider).path,
                ),
              );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (widget.stream is ThumbnailStreamInfo
                            ? widget.stream.containerName as String
                            : widget.stream is AudioOnlyStreamInfo
                                ? widget.stream.audioCodec
                                    .split('.')[0]
                                    .replaceAll('mp4a', 'm4a') as String
                                : widget.stream.container.name as String)
                        .toUpperCase(),
                  ),
                  Text(
                    widget.stream is ThumbnailStreamInfo
                        ? ''
                        : (widget.stream.size.totalBytes as int).getFileSize(),
                  ),
                ],
              ),
              Align(
                child: Text(
                  widget.stream is VideoStreamInfo
                      ? (widget.stream as VideoStreamInfo).qualityLabel
                      : widget.stream is AudioOnlyStreamInfo
                          ? (widget.stream as AudioOnlyStreamInfo)
                              .bitrate
                              .bitsPerSecond
                              .getBitrate()
                          : widget.stream is ThumbnailStreamInfo
                              ? (widget.stream as ThumbnailStreamInfo).name
                              : '',
                  style: context.textTheme.headline5,
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

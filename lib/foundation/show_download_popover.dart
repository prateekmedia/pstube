import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/states/states.dart';
import 'package:pstube/ui/widgets/widgets.dart';

final Widget _progressIndicator = SizedBox(
  height: 100,
  child: getCircularProgressIndicator(),
);

Future<dynamic> showDownloadPopup(
  BuildContext context, {
  VideoData? video,
  String? videoUrl,
  bool isClickable = false,
}) {
  assert(
    video != null || videoUrl != null,
    "Both video and videoUrl can't be null",
  );
  Future<Response<VideoInfo>?> getVideo() =>
      PipedApi().getUnauthenticatedApi().streamInfo(
            videoId: videoUrl!,
          );
  return showPopover(
    context: context,
    title: context.locals.downloadQuality,
    padding: EdgeInsets.symmetric(
      horizontal: context.isMobile ? 14 : 26,
      vertical: 6,
    ),
    builder: (ctx) => FutureBuilder<Response<VideoInfo>?>(
      future: videoUrl != null ? getVideo() : null,
      builder: (context, snapshot) {
        return video != null ||
                snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.data != null
            ? DownloadsWidget(
                isClickable: isClickable,
                video: video ??
                    VideoData.fromVideoInfo(
                      snapshot.data!.data!,
                      VideoId(videoUrl!),
                    ),
              )
            : snapshot.hasError
                ? Text(context.locals.error)
                : _progressIndicator;
      },
    ),
  );
}

class DownloadsWidget extends ConsumerWidget {
  const DownloadsWidget({
    super.key,
    required this.video,
    this.onClose,
    this.isClickable = false,
  });

  final VideoData video;
  final VoidCallback? onClose;
  final bool isClickable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<VideoData?> getVideo() async {
      final res = await PipedApi().getUnauthenticatedApi().streamInfo(
            videoId: video.id.value,
          );

      if (res.data == null) return null;

      return VideoData.fromVideoInfo(res.data!, video.id);
    }

    return SafeArea(
      child: FutureBuilder<VideoData?>(
        future: video.audioStreams == null ? getVideo() : null,
        builder: (context, snapshot) {
          final data = video.audioStreams != null ? video : snapshot.data;

          return snapshot.hasData || data != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PSVideo(
                      videoData: video,
                      isRow: true,
                      isInsidePopup: true,
                      isClickable: isClickable,
                    ),
                    AdwActionRow(
                      contentPadding: EdgeInsets.zero,
                      onActivated:
                          ref.read(rememberChoiceProvider.notifier).toggle,
                      start: Checkbox(
                        value: ref.watch(rememberChoiceProvider),
                        onChanged: (value) => ref
                            .read(rememberChoiceProvider.notifier)
                            .value = value!,
                      ),
                      title: 'Remember my choice',
                    ),
                    if (ref.watch(thumbnailDownloaderProvider)) ...[
                      linksHeader(
                        context,
                        icon: Icons.video_call,
                        label: context.locals.thumbnail,
                        padding: const EdgeInsets.only(top: 6, bottom: 14),
                      ),
                      for (var thumbnail
                          in video.thumbnails.toStreamInfo(context))
                        DownloadQualityTile.thumbnail(
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
                    for (var videoStream in data!.videoStreams!
                        .where((p0) => !(p0.videoOnly ?? false))
                        .toList()
                        .reversed)
                      DownloadQualityTile(
                        stream: videoStream,
                        video: video,
                        onClose: onClose,
                      ),
                    linksHeader(
                      context,
                      icon: Icons.audiotrack,
                      label: context.locals.audioOnly,
                    ),
                    for (var audioStream in data.audioStreams!)
                      DownloadQualityTile(
                        stream: audioStream,
                        video: video,
                        onClose: onClose,
                      ),
                    linksHeader(
                      context,
                      icon: Icons.videocam,
                      label: context.locals.videoOnly,
                    ),
                    for (var videoStream in data.videoStreams!
                        .where((p0) => p0.videoOnly ?? false)
                        .toList())
                      DownloadQualityTile(
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

class DownloadQualityTile extends HookConsumerWidget {
  DownloadQualityTile({
    super.key,
    required Stream stream,
    required this.video,
    this.onClose,
  }) : stream = StreamData(
          quality: stream.quality!,
          format: stream.format!.getName,
          url: stream.url!,
        );

  DownloadQualityTile.thumbnail({
    super.key,
    required ThumbnailStreamInfo stream,
    required this.video,
    this.onClose,
  }) : stream = StreamData(
          quality: stream.name,
          format: stream.containerName,
          url: stream.url,
        );

  final StreamData stream;
  final VideoData video;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = useState<int>(0);
    final isMounted = useIsMounted();

    Future<void> getSize() async {
      final dio = Dio();
      try {
        // ignore: inference_failure_on_function_invocation
        final r = await dio.head(stream.url);
        if (!isMounted()) return;
        size.value = int.tryParse(r.headers['content-length']![0]) ?? 0;
      } catch (e) {
        debugPrint('$e');
      }
    }

    useEffect(
      () {
        if (size.value == 0) {
          getSize();
        }
        return;
      },
      [],
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () async {
          if ((Platform.isAndroid || Platform.isIOS) &&
                  !await Permission.storage.request().isGranted ||
              !await Permission.accessMediaLocation.request().isGranted &&
                  !await Permission.manageExternalStorage.request().isGranted) {
            return;
          }
          if (!isMounted()) return;
          onClose != null ? onClose!() : context.back();

          await ref.read(downloadListProvider.notifier).addDownload(
                context,
                DownloadItem.fromVideo(
                  video: video,
                  stream: stream,
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
                    stream.format,
                  ),
                  Text(
                    size.value.getFileSize(),
                  ),
                ],
              ),
              Align(
                child: Text(
                  stream.quality,
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

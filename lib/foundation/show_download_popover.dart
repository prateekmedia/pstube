import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:libadwaita/libadwaita.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/foundation/view_model/video_info_view_model.dart';
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

  return showPopover(
    context: context,
    title: context.locals.downloadQuality,
    padding: EdgeInsets.symmetric(
      horizontal: context.isMobile ? 14 : 26,
      vertical: 6,
    ),
    builder: (_) => _DownloadWrapper(
      video: video,
      videoUrl: videoUrl,
      isClickable: isClickable,
    ),
  );
}

class _DownloadWrapper extends ConsumerWidget {
  const _DownloadWrapper({
    required this.video,
    required this.videoUrl,
    required this.isClickable,
  });

  final VideoData? video;
  final String? videoUrl;
  final bool isClickable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoData = videoUrl != null || video?.audioStreams == null
        ? ref.read(
            videoInfoProvider(
              videoUrl != null ? VideoId(videoUrl!) : video!.id,
            ),
          )
        : null;

    final loadedVideo = video?.videoStreams != null ? video! : videoData!.value;

    return loadedVideo != null
        ? DownloadsWidget(
            isClickable: isClickable,
            video: loadedVideo,
          )
        : videoData!.isLoading
            ? _progressIndicator
            : Text(context.locals.error);
  }
}

class DownloadsWidget extends ConsumerWidget {
  const DownloadsWidget({
    required this.video,
    super.key,
    this.onClose,
    this.isClickable = false,
  });

  final VideoData video;
  final VoidCallback? onClose;
  final bool isClickable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
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
            onActivated: ref.read(rememberChoiceProvider.notifier).toggle,
            start: Checkbox(
              value: ref.watch(rememberChoiceProvider),
              onChanged: (value) =>
                  ref.read(rememberChoiceProvider.notifier).value = value!,
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
            for (var thumbnail in video.thumbnails.toStreamInfo(context))
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
          for (var videoStream in video.videoStreams!
              .where((p0) => !(p0.videoOnly ?? false))
              .toList()
              .reversed)
            DownloadQualityTile(
              stream: StreamData.fromStream(stream: videoStream),
              video: video,
              onClose: onClose,
            ),
          linksHeader(
            context,
            icon: Icons.audiotrack,
            label: context.locals.audioOnly,
          ),
          for (var audioStream in video.audioStreams!)
            DownloadQualityTile(
              stream: StreamData.fromStream(stream: audioStream),
              video: video,
              onClose: onClose,
            ),
          linksHeader(
            context,
            icon: Icons.videocam,
            label: context.locals.videoOnly,
          ),
          for (var videoStream in video.videoStreams!
              .where((p0) => p0.videoOnly ?? false)
              .toList())
            DownloadQualityTile(
              stream: StreamData.fromStream(stream: videoStream),
              video: video,
              onClose: onClose,
            ),
        ],
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
          style: context.textTheme.headlineSmall,
        )
      ],
    ),
  );
}

class DownloadQualityTile extends HookConsumerWidget {
  const DownloadQualityTile({
    required this.stream,
    required this.video,
    super.key,
    this.onClose,
  });

  DownloadQualityTile.thumbnail({
    required ThumbnailStreamInfo stream,
    required this.video,
    super.key,
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

    Future<void> getSize() async {
      final client = http.Client();
      try {
        final r = await client.head(
          Uri.parse(stream.url),
        );
        if (r.statusCode == 200) {
          final length = r.headers['content-length'];
          if (length != null) {
            final sizeP = int.tryParse(length);
            if (sizeP != null && context.mounted) {
              size.value = sizeP;
            }
          }
        }
      } catch (e) {
        debugPrint('$e');
      } finally {
        client.close();
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
          if (context.mounted) {
            onClose != null ? onClose!() : context.back();

            await ref.read(downloadListProvider.notifier).addDownload(
                  context,
                  DownloadItem.fromVideo(
                    video: video,
                    stream: stream,
                    path: ref.watch(downloadPathProvider).path,
                  ),
                );
          }
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
                  style: context.textTheme.headlineSmall,
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

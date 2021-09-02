import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/models/models.dart';
import 'package:flutube/providers/providers.dart';
import 'package:open_file/open_file.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final downloadListUtils = ref.watch(downloadListProvider);
    final downloadList = downloadListUtils.downloadList;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      children: [
        if (downloadList.isEmpty) ...[
          const SizedBox(height: 60),
          const Icon(Icons.file_download_off_outlined, size: 30),
          const SizedBox(height: 10),
          const Text('No Downloads found').center()
        ] else
          for (DownloadItem item in downloadList)
            DownloadItemBuilder(
                item: item, downloadListUtils: downloadListUtils),
      ],
    );
  }
}

class DownloadItemBuilder extends StatelessWidget {
  const DownloadItemBuilder({
    Key? key,
    required this.item,
    required this.downloadListUtils,
  }) : super(key: key);

  final DownloadItem item;
  final DownloadList downloadListUtils;

  @override
  Widget build(BuildContext context) {
    var yt = YoutubeExplode();
    return GestureDetector(
      onTap: () => OpenFile.open(item.queryVideo.path + item.queryVideo.name),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.pushPage(FutureBuilder<Video>(
                  future: yt.videos
                      .get(item.queryVideo.id)
                      .whenComplete(() => yt.close()),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? VideoScreen(
                            video: snapshot.data!,
                            loadData: true,
                          )
                        : Scaffold(
                            appBar: AppBar(
                              leading: IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: context.back,
                              ),
                            ),
                            body: const CircularProgressIndicator().center());
                  }));
            },
            child: Stack(
              children: [
                Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    child: CachedNetworkImage(
                      imageUrl: item.queryVideo.thumbnail,
                      fit: BoxFit.fill,
                    )),
                Positioned.fill(
                  child: Align(
                    alignment: const Alignment(0.98, 0.94),
                    child: IconWithLabel(
                      label: item.queryVideo.duration.format(),
                      secColor: SecColor.dark,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.queryVideo.name),
                  Text(
                      '${((item.downloaded / item.total) * 100).toStringAsFixed(1)}% • ${item.total.getFileSize()}')
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: item.cancelToken!.isCancelled ||
                    item.total == 0 ||
                    item.total == item.downloaded
                ? () => showPopoverWB(
                    context: context,
                    title: "Are you Sure?",
                    onConfirm: () {
                      if (File(item.queryVideo.path + item.queryVideo.name)
                          .existsSync()) {
                        File(item.queryVideo.path + item.queryVideo.name)
                            .deleteSync();
                      }
                      downloadListUtils.removeDownload(item.queryVideo);
                      context.back();
                    })
                : () {
                    item.cancelToken!.cancel();
                    downloadListUtils.refresh();
                  },
            icon: Icon(
              item.cancelToken!.isCancelled
                  ? Icons.remove
                  : item.total != 0 && item.total != item.downloaded
                      ? Icons.close
                      : Icons.delete,
            ),
          )
        ],
      ),
    );
  }
}

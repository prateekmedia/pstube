import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutube/models/models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final downloadListProvider = ChangeNotifierProvider((ref) => DownloadList(ref));

class DownloadList extends ChangeNotifier {
  final ProviderRefBase ref;
  DownloadList(this.ref);

  List<DownloadItem> downloadList = [];

  addDownload(DownloadItem downloadItem) async {
    final CancelToken cancelToken = CancelToken();

    downloadList.add(downloadItem.copyWith(cancelToken: cancelToken));
    notifyListeners();
    await Dio().download(downloadItem.queryVideo.url,
        downloadItem.queryVideo.path + downloadItem.queryVideo.name,
        onReceiveProgress: (downloaded, total) {
      updateDownload(downloadItem.queryVideo,
          downloaded: downloaded, total: total);
    }, cancelToken: cancelToken);
  }

  updateDownload(
    QueryVideo queryVideo, {
    required int downloaded,
    int? total,
  }) {
    var currentItemIndex =
        downloadList.indexWhere((e) => e.queryVideo == queryVideo);
    downloadList[currentItemIndex] = downloadList[currentItemIndex]
        .copyWith(downloaded: downloaded, total: total);
    notifyListeners();
  }
}

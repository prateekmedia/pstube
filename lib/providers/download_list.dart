import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutube/models/models.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final downloadListProvider = ChangeNotifierProvider((ref) => DownloadList(ref));

final _box = Hive.box('downloadList');

class DownloadList extends ChangeNotifier {
  final ProviderRefBase ref;
  DownloadList(this.ref);

  List<DownloadItem> downloadList = (_box.get('value', defaultValue: []) as List)
      .map((e) => DownloadItem(queryVideo: e[1], downloaded: e[0], total: e[0]))
      .toList();

  void addDownload(DownloadItem downloadItem) async {
    final CancelToken cancelToken = CancelToken();

    downloadList.insert(0, downloadItem.copyWith(cancelToken: cancelToken));
    refresh();
    BotToast.showText(text: "Download started!");
    await Dio().download(downloadItem.queryVideo.url, downloadItem.queryVideo.path + downloadItem.queryVideo.name,
        onReceiveProgress: (downloaded, total) {
      updateDownload(downloadItem.queryVideo, downloaded: downloaded, total: total);
    }, cancelToken: cancelToken);
    DownloadItem currentItem = downloadList.firstWhere((e) => e.queryVideo == downloadItem.queryVideo);
    if (currentItem.downloaded == currentItem.total && currentItem.total != 0) refresh(true);
    BotToast.showText(text: "Download finished!");
  }

  refresh([bool? value]) {
    notifyListeners();
    if (value != null) {
      _box.put('value', downloadList.map((e) => [e.total, e.queryVideo]).toList());
    }
  }

  updateDownload(
    QueryVideo queryVideo, {
    required int downloaded,
    int? total,
  }) {
    var currentItemIndex = downloadList.indexWhere((e) => e.queryVideo == queryVideo);
    downloadList[currentItemIndex] = downloadList[currentItemIndex].copyWith(downloaded: downloaded, total: total);
    notifyListeners();
  }

  removeDownload(
    QueryVideo queryVideo,
  ) {
    var currentItemIndex = downloadList.indexWhere((e) => e.queryVideo == queryVideo);
    downloadList.removeAt(currentItemIndex);
    refresh(true);
  }

  clearAll() {
    downloadList = [];
    refresh(true);
  }
}

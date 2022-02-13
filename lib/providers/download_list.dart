import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:sftube/models/models.dart';
import 'package:sftube/utils/utils.dart';

final downloadListProvider = ChangeNotifierProvider((ref) => DownloadList(ref));

final _box = Hive.box<dynamic>('downloadList');

class DownloadList extends ChangeNotifier {
  DownloadList(this.ref);

  final ChangeNotifierProviderRef ref;

  List<DownloadItem> downloadList =
      (_box.get('value', defaultValue: <dynamic>[]) as List)
          .map(
            (dynamic e) => DownloadItem(
              queryVideo: e[1] as QueryVideo,
              downloaded: e[0] as int,
              total: e[0] as int,
            ),
          )
          .toList();

  String? get downloading {
    final downloading = downloadList
        .where((element) => element.downloaded != element.total)
        .length;
    return downloading != 0 ? downloading.toString() : null;
  }

  Future<void> addDownload(
    BuildContext context,
    DownloadItem downloadItem,
  ) async {
    final cancelToken = CancelToken();

    downloadList.insert(0, downloadItem.copyWith(cancelToken: cancelToken));
    refresh();
    BotToast.showText(text: context.locals.downloadStarted);
    await Dio().download(
      downloadItem.queryVideo.url,
      downloadItem.queryVideo.path + downloadItem.queryVideo.name,
      onReceiveProgress: (downloaded, total) {
        updateDownload(
          downloadItem.queryVideo,
          downloaded: downloaded,
          total: total,
        );
      },
      cancelToken: cancelToken,
    );
    final currentItem =
        downloadList.firstWhere((e) => e.queryVideo == downloadItem.queryVideo);
    if (currentItem.downloaded == currentItem.total && currentItem.total != 0) {
      refresh(value: true);
    }
    BotToast.showText(text: context.locals.downloadFinished);
  }

  void refresh({bool? value}) {
    notifyListeners();
    if (value != null) {
      _box.put(
        'value',
        downloadList.map((e) => [e.total, e.queryVideo]).toList(),
      );
    }
  }

  void updateDownload(
    QueryVideo queryVideo, {
    required int downloaded,
    int? total,
  }) {
    final currentItemIndex =
        downloadList.indexWhere((e) => e.queryVideo == queryVideo);
    downloadList[currentItemIndex] = downloadList[currentItemIndex]
        .copyWith(downloaded: downloaded, total: total);
    notifyListeners();
  }

  void removeDownload(
    QueryVideo queryVideo,
  ) {
    final currentItemIndex =
        downloadList.indexWhere((e) => e.queryVideo == queryVideo);
    downloadList.removeAt(currentItemIndex);
    refresh(value: true);
  }

  void clearAll() {
    downloadList = [];
    refresh(value: true);
  }
}

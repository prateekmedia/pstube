import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutube/utils/shared_prefs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final downloadPathProvider =
    ChangeNotifierProvider((_) => DownloadPathNotifier());

class DownloadPathNotifier extends ChangeNotifier {
  late String _path;
  String get path => _path;

  set path(String? newPath) {
    if (newPath != null && newPath != path && Directory(newPath).existsSync()) {
      MyPrefs().prefs.setString('downloadPath', newPath);
      _path = newPath;
      notifyListeners();
    }
  }

  init() async {
    _path = MyPrefs().prefs.getString('downloadPath') ??
        (Platform.isAndroid
            ? "/storage/emulated/0/FluTube"
            : (await getDownloadsDirectory())!
                .path
                .replaceAll('Downloads', 'FluTube/'));
    if (!await Directory(path).exists()) await Directory(path).create();
  }
}

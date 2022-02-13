import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sftube/utils/utils.dart';

final downloadPathProvider =
    ChangeNotifierProvider((_) => DownloadPathNotifier());

class DownloadPathNotifier extends ChangeNotifier {
  late String _path;
  String get path => _path;

  set path(String? newPath) {
    if (newPath != null && newPath != path && Directory(newPath).existsSync()) {
      final _newPath =
          newPath.endsWith('/') || Platform.isWindows && newPath.endsWith(r'\')
              ? newPath
              : newPath + (Platform.isWindows ? r'\' : '/');
      MyPrefs().prefs.setString('downloadPath', _newPath);
      _path = _newPath;
      notifyListeners();
    }
  }

  Future<void> init() async {
    if (kIsWeb) return;
    _path = MyPrefs().prefs.getString('downloadPath') ??
        (Platform.isAndroid
            ? '/storage/emulated/0/Download/${myApp.nickname!}/'
            : p.join((await getDownloadsDirectory())!.path, myApp.nickname) +
                (Platform.isWindows ? r'\' : '/'));
    if (Platform.isAndroid && !await Permission.storage.request().isGranted) {
      return;
    }
    if (!Directory(path).existsSync()) await Directory(path).create();
  }

  void reset() {
    MyPrefs().prefs.remove('downloadPath').whenComplete(init);
  }
}

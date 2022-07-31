import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/foundation/controller/internet_connectivity.dart';
import 'package:pstube/foundation/services.dart';
import 'package:window_manager/window_manager.dart';

class Configuration {
  static Future<void> init() async {
    if (Constants.isDesktop) {
      await windowManager.ensureInitialized();

      const windowOptions = WindowOptions(
        size: Size(1000, 600),
        // minimumSize: Size(400, 450),
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }

    // Intialize Dart VLC
    if (!Constants.isDesktop) {
      await DartVLC.initialize();
    }

    // Connectivity check stream initialised.
    await InternetConnectivity.networkStatusService();

    // Initialize SharedPreferences
    await MyPrefs().init();

    // Initialize Hive database
    Hive
      ..registerAdapter(LikedCommentAdapter())
      ..registerAdapter(QueryVideoAdapter());
    await Hive.initFlutter(
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS
          ? (await getApplicationDocumentsDirectory()).path
          : (await getDownloadsDirectory())!
              .path
              .replaceFirst('Downloads', '.pstube'),
    );

    await Hive.openBox<dynamic>('playlist');
    await Hive.openBox<List<dynamic>>('likedList');
    await Hive.openBox<dynamic>('downloadList');
    await Hive.openBox<List<dynamic>>('historyList');
  }
}

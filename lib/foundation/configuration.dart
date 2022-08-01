import 'dart:async';
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
  static const windowOptions = WindowOptions(
    size: Size(1000, 600),
    minimumSize: Size(400, 450),
    skipTaskbar: false,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'PsTube',
  );

  static Future<void> initWindowManager() async {
    await windowManager.ensureInitialized();

    unawaited(
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        if (Platform.isLinux) await windowManager.setAsFrameless();
        await windowManager.show();
        await windowManager.focus();
      }),
    );
  }

  static Future<void> init() async {
    if (Constants.isDesktop) {
      await initWindowManager();
      await DartVLC.initialize(useFlutterNativeView: Platform.isWindows);
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

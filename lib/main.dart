import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_gen/gen_l10n/app_locals.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutube/home_page.dart';
import 'package:flutube/utils/utils.dart';
import 'package:flutube/models/models.dart';
import 'package:flutube/providers/providers.dart';
import 'package:flutube/controller/internet_connectivity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Connectivity check stream initialised.
  InternetConnectivity.networkStatusService();

  // Initialize SharedPreferences
  await MyPrefs().init();

  // Initialize Hive database
  Hive.registerAdapter(LikedCommentAdapter());
  Hive.registerAdapter(QueryVideoAdapter());
  await Hive.initFlutter(
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS
          ? (await getApplicationDocumentsDirectory()).path
          : (await getDownloadsDirectory())!
              .path
              .replaceFirst('Downloads', '.flutube'));
  await Hive.openBox('playlist');
  await Hive.openBox('likedList');
  await Hive.openBox('downloadList');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    ref.read(downloadPathProvider).init();
    final botToastBuilder = BotToastInit();
    return MaterialApp(
      title: myApp.name,
      builder: (context, child) {
        // child = myBuilder(context,child);  //do something
        child = botToastBuilder(context, child);
        return child;
      },
      navigatorObservers: [BotToastNavigatorObserver()],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: getThemeData(context, Brightness.light),
      darkTheme: getThemeData(context, Brightness.dark),
      themeMode: ref.watch(themeTypeProvider),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

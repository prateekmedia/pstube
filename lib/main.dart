import 'dart:io';

import 'package:adwaita/adwaita.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locals.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutube/controller/internet_connectivity.dart';
import 'package:flutube/home_page.dart';
import 'package:flutube/models/models.dart';
import 'package:flutube/providers/providers.dart';
import 'package:flutube/utils/utils.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
            .replaceFirst('Downloads', '.flutube'),
  );
  await Hive.openBox<dynamic>('playlist');
  await Hive.openBox<List>('likedList');
  await Hive.openBox<dynamic>('downloadList');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(downloadPathProvider).init();
    final botToastBuilder = BotToastInit();
    return MaterialApp(
      title: myApp.name,
      builder: (context, child) {
        Widget myBuilder(BuildContext ctx, Widget child) {
          return ScrollConfiguration(
            behavior: const CupertinoScrollBehavior(),
            child: child,
          );
        }

        child = myBuilder(context, child!);
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
      theme: AdwaitaThemeData.light(fontFamily: 'Noto Sans'),
      darkTheme: AdwaitaThemeData.dark(fontFamily: 'Noto Sans'),
      themeMode: ref.watch(themeTypeProvider),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

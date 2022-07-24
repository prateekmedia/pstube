import 'dart:io';

import 'package:adwaita/adwaita.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locals.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pstube/config/info/app_info.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/foundation/controller/internet_connectivity.dart';
import 'package:pstube/foundation/services.dart';
import 'package:pstube/states/states.dart';
import 'package:pstube/ui/screens/home_page/home_page.dart';
import 'package:responsive_framework/responsive_framework.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Intialize Dart VLC
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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

  runApp(const ProviderScope(child: MyApp()));
  if (!Constants.mobVideoPlatforms) {
    doWhenWindowReady(() {
      final win = appWindow!;
      const initialSize = Size(400, 450);
      const size = Size(1000, 600);
      win
        ..title = 'PsTube'
        ..size = size
        ..alignment = Alignment.center
        ..minSize = initialSize
        ..show();
    });
  }
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final botToastBuilder = BotToastInit();
    useEffect(
      () {
        ref.read(downloadPathProvider).init();
        return;
      },
      [],
    );
    return MaterialApp(
      title: AppInfo.myApp.name,
      builder: (context, child) {
        Widget myBuilder(BuildContext ctx, Widget child) {
          return ResponsiveWrapper.builder(
            child,
            minWidth: 480,
            defaultScale: true,
            defaultScaleLandscape: true,
            defaultScaleFactor: 1.11,
            defaultScaleFactorLandscape: 0.9,
            breakpoints: [
              const ResponsiveBreakpoint.resize(480, name: MOBILE),
              const ResponsiveBreakpoint.resize(800, name: TABLET),
              const ResponsiveBreakpoint.resize(1000, name: DESKTOP),
            ],
          );
        }

        child = botToastBuilder(context, child);
        child = myBuilder(context, child);
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
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (supportedLocales.contains(deviceLocale)) {
          return deviceLocale;
        }
        return const Locale('en');
      },
      theme: AdwaitaThemeData.light(fontFamily: 'Noto Sans').copyWith(
        useMaterial3: true,
        primaryColor: Colors.red,
      ),
      darkTheme: AdwaitaThemeData.dark(fontFamily: 'Noto Sans').copyWith(
        primaryColor: Colors.red,
        useMaterial3: true,
      ),
      themeMode: ref.watch(themeTypeProvider),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

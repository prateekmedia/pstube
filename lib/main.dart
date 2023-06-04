import 'package:adwaita/adwaita.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locals.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/config/info/app_info.dart';
import 'package:pstube/foundation/configuration.dart';
import 'package:pstube/foundation/controller/scrollable.dart';
import 'package:pstube/states/states.dart';
import 'package:pstube/ui/screens/home_page/home_page.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Configuration.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final botToastBuilder = BotToastInit();
    final virtualWindowFrameBuilder = VirtualWindowFrameInit();
    useEffect(
      () {
        ref.read(downloadPathProvider).init();
        return;
      },
      [],
    );

    return MaterialApp(
      title: AppInfo.myApp.name,
      scrollBehavior: CustomScrollBehavior(),
      builder: (context, child) {
        Widget responsiveBuilder(BuildContext ctx, Widget child) {
          return ResponsiveBreakpoints.builder(
            child: child,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1920, name: DESKTOP),
              const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
          );
        }

        child = virtualWindowFrameBuilder(context, child);
        child = botToastBuilder(context, child);
        child = responsiveBuilder(context, child);
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
      theme: AdwaitaThemeData.light(fontFamily: 'Noto Sans').copyWith(
        primaryColor: Colors.red,
      ),
      darkTheme: AdwaitaThemeData.dark(fontFamily: 'Noto Sans').copyWith(
        primaryColor: Colors.red,
      ),
      themeMode: ref.watch(themeTypeProvider),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

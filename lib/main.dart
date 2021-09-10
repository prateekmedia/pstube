import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MyPrefs().init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    ref.read(downloadPathProvider).init();
    final botToastBuilder = BotToastInit();
    return MaterialApp(
      title: 'FluTube',
      builder: (context, child) {
        // child = myBuilder(context,child);  //do something
        child = botToastBuilder(context, child);
        return child;
      },
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red,
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',
      ),
      themeMode: ref.watch(themeTypeProvider),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  MyHomePage({Key? key}) : super(key: key);

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final _currentIndex = useState<int>(0);
    final extendedRail = useState<bool>(false);

    final mainScreens = [
      const HomeScreen(),
      const LikedScreen(),
      const DownloadsScreen(),
      const SettingsScreen(),
    ];

    final Map<String, List<IconData>> navItems = {
      "Home": [Ionicons.home_outline, Ionicons.home],
      "Liked": [Icons.thumb_up_outlined, Icons.thumb_up],
      "Downloads": [Ionicons.download_outline, Ionicons.download],
      "Settings": [Ionicons.settings_outline, Ionicons.settings_sharp],
    };

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: context.textTheme.bodyText1!.color,
        backgroundColor: context.getAltBackgroundColor,
        title: Row(
          children: [
            if (context.width >= mobileWidth) ...[
              GestureDetector(
                onTap: () => extendedRail.value = !extendedRail.value,
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.menu),
                ),
              ),
              const SizedBox(width: 15),
            ],
            const Text('FluTube'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => showSearch(context: context, delegate: CustomSearchDelegate()),
            icon: const Icon(Ionicons.search, size: 20),
          ),
          if (_currentIndex.value == 3)
            Consumer(builder: (context, ref, _) {
              return PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: const Text('Reset default'),
                      onTap: () => resetDefaults(ref),
                    )
                  ];
                },
              );
            }),
          const SizedBox(width: 10),
        ],
      ),
      body: Row(
        children: [
          if (context.width >= mobileWidth)
            NavigationRail(
              destinations: [
                for (var item in navItems.entries)
                  NavigationRailDestination(
                    label: Text(item.key, style: context.textTheme.bodyText1),
                    icon: Icon(item.value[0]),
                    selectedIcon: Icon(item.value[1]),
                  ),
              ],
              extended: extendedRail.value,
              backgroundColor: context.getAltBackgroundColor,
              selectedIndex: _currentIndex.value,
              onDestinationSelected: (index) => _controller.animateToPage(index,
                  duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn),
            ),
          Flexible(
            child: PageView.builder(
              controller: _controller,
              itemBuilder: (context, index) => mainScreens[index],
              onPageChanged: (index) => _currentIndex.value = index,
              itemCount: mainScreens.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Visibility(
        visible: (context.width < mobileWidth),
        child: Container(
          margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          padding: const EdgeInsets.all(6),
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: context.getAltBackgroundColor,
          ),
          child: SalomonBottomBar(
            selectedItemColor: context.textTheme.bodyText1!.color,
            unselectedItemColor: context.getAlt2BackgroundColor,
            items: [
              for (var item in navItems.entries)
                SalomonBottomBarItem(
                  title: Text(item.key),
                  icon: Icon(item.value[0], size: 20),
                  activeIcon: Icon(item.value[1], size: 20),
                ),
            ],
            currentIndex: _currentIndex.value,
            onTap: (index) => _controller.animateToPage(index,
                duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn),
          ),
        ),
      ),
    );
  }
}

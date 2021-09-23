import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutube/controller/internet_connectivity.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/models/models.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:flutube/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Connectivity check stream initialised.
  InternetConnectivity.networkStatusService();

  // Initialize SharedPreferences
  await MyPrefs().init();

  // Initialize Hive database
  Hive.registerAdapter(LikedCommentAdapter());
  Hive.registerAdapter(QueryVideoAdapter());
  await Hive.initFlutter();
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
      theme: getThemeData(context, Brightness.light),
      darkTheme: getThemeData(context, Brightness.dark),
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
    final _addDownloadController = TextEditingController();

    final mainScreens = [
      const HomeScreen(),
      const LikedScreen(),
      const PlaylistScreen(),
      const DownloadsScreen(),
      const SettingsScreen(),
    ];

    final Map<String, List<IconData>> navItems = {
      "Home": [LucideIcons.home],
      "Liked": [LucideIcons.thumbsUp],
      "Playlist": [Icons.playlist_add],
      "Downloads": [LucideIcons.download],
      "Settings": [LucideIcons.settings],
    };

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            if (!context.isMobile) ...[
              GestureDetector(
                onTap: () => extendedRail.value = !extendedRail.value,
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(LucideIcons.menu),
                ),
              ),
              const SizedBox(width: 15),
            ],
            Text(myApp.name),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => showSearch(context: context, delegate: CustomSearchDelegate()),
            icon: const Icon(LucideIcons.search, size: 20),
          ),
          if (_currentIndex.value == 4)
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
          if (!context.isMobile)
            NavigationRail(
              destinations: [
                for (var item in navItems.entries)
                  NavigationRailDestination(
                    label: Text(item.key, style: context.textTheme.bodyText1),
                    icon: Icon(item.value[0]),
                    selectedIcon: Icon(item.value.length == 2 ? item.value[1] : item.value[0]),
                  ),
              ],
              minExtendedWidth: 200,
              extended: extendedRail.value,
              selectedIndex: _currentIndex.value,
              onDestinationSelected: (index) => _controller.jumpToPage(index),
            ),
          Flexible(
            child: FtBody(
              child: PageView.builder(
                controller: _controller,
                itemCount: mainScreens.length,
                itemBuilder: (context, index) => mainScreens[index],
                onPageChanged: (index) => _currentIndex.value = index,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentIndex.value == 0
          ? FloatingActionButton(
              onPressed: () async {
                if (_addDownloadController.text.isEmpty) {
                  var clipboard = await Clipboard.getData(Clipboard.kTextPlain);
                  var youtubeRegEx = RegExp(
                      r"^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$");
                  if (clipboard != null && clipboard.text != null && youtubeRegEx.hasMatch(clipboard.text!)) {
                    _addDownloadController.text = clipboard.text!;
                  }
                }
                showPopoverWB(
                  context: context,
                  onConfirm: () {
                    context.back();
                    if (_addDownloadController.value.text.isNotEmpty) {
                      showDownloadPopup(context, videoUrl: _addDownloadController.text);
                    }
                  },
                  hint: "https://youtube.com/watch?v=***********",
                  title: "Download from video url",
                  controller: _addDownloadController,
                );
              },
              child: const Icon(LucideIcons.plus),
            )
          : null,
      bottomNavigationBar: Visibility(
        visible: context.isMobile,
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
                  activeIcon: Icon(item.value.length == 2 ? item.value[1] : item.value[0], size: 20),
                ),
            ],
            currentIndex: _currentIndex.value,
            onTap: (index) => _controller.jumpToPage(index),
          ),
        ),
      ),
    );
  }
}

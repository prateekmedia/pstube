import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
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
    return MaterialApp(
      title: 'FluTube',
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: context.textTheme.bodyText1!.color,
        backgroundColor: context.isDark ? Colors.grey[900]! : Colors.grey[300]!,
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
          if (_currentIndex.value == 2)
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
                NavigationRailDestination(
                  label: Text("Home", style: context.textTheme.bodyText1),
                  icon: const Icon(Ionicons.home_outline),
                  selectedIcon: const Icon(Ionicons.home),
                ),
                NavigationRailDestination(
                  label: Text("Downloads", style: context.textTheme.bodyText1),
                  icon: const Icon(Ionicons.download_outline),
                  selectedIcon: const Icon(Ionicons.download),
                ),
                NavigationRailDestination(
                  label: Text("Settings", style: context.textTheme.bodyText1),
                  icon: const Icon(Ionicons.settings_outline),
                  selectedIcon: const Icon(Ionicons.settings_sharp),
                ),
              ],
              extended: extendedRail.value,
              backgroundColor: context.isDark ? Colors.grey[900]! : Colors.grey[300]!,
              selectedIndex: _currentIndex.value,
              onDestinationSelected: (index) => _controller.animateToPage(index,
                  duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn),
            ),
          Flexible(
            child: PageView.builder(
              controller: _controller,
              itemBuilder: (context, index) => [
                const HomeScreen(),
                const DownloadsScreen(),
                const SettingsScreen(),
              ][index],
              onPageChanged: (index) => _currentIndex.value = index,
              itemCount: 3,
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
            color: context.isDark ? Colors.grey[900]! : Colors.grey[300]!,
          ),
          child: SalomonBottomBar(
            selectedItemColor: context.textTheme.bodyText1!.color,
            unselectedItemColor: context.isDark ? Colors.grey[400] : Colors.grey[600]!,
            items: [
              SalomonBottomBarItem(
                title: const Text("Home"),
                icon: const Icon(Ionicons.home_outline, size: 20),
                activeIcon: const Icon(Ionicons.home_sharp, size: 20),
              ),
              SalomonBottomBarItem(
                title: const Text("Downloads"),
                icon: const Icon(Ionicons.download_outline, size: 20),
                activeIcon: const Icon(Ionicons.download_sharp, size: 20),
              ),
              SalomonBottomBarItem(
                title: const Text("Settings"),
                icon: const Icon(Ionicons.settings_outline, size: 20),
                activeIcon: const Icon(Ionicons.settings_sharp, size: 20),
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

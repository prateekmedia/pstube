import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/utils/utils.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FluTube',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red,
        primarySwatch: Colors.red,
      ),
      themeMode: ThemeMode.dark,
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
        backgroundColor: Colors.grey[900]!,
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
            Flexible(
              child: Hero(
                tag: 'search',
                child: Material(
                  type: MaterialType.transparency,
                  child: TextField(
                    onTap: () {
                      context.pushPage(const SearchScreen());
                    },
                    readOnly: true,
                    enableInteractiveSelection: false,
                    decoration: InputDecoration(
                      hintText: "Search",
                      isDense: true,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide:
                            BorderSide(color: Colors.grey[800]!, width: 0.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide:
                            BorderSide(color: Colors.grey[700]!, width: 0.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide:
                            BorderSide(color: Colors.grey[800]!, width: 0.0),
                      ),
                      filled: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Ionicons.person_outline),
          ),
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
                  icon: const Icon(Ionicons.home, color: Colors.white),
                ),
                NavigationRailDestination(
                  label: Text("Downloads", style: context.textTheme.bodyText1),
                  icon: const Icon(Ionicons.download_outline,
                      color: Colors.white),
                ),
                NavigationRailDestination(
                  label: Text("Settings", style: context.textTheme.bodyText1),
                  icon:
                      const Icon(Ionicons.settings_sharp, color: Colors.white),
                ),
              ],
              extended: extendedRail.value,
              backgroundColor: Colors.grey[900]!,
              selectedIndex: _currentIndex.value,
              onDestinationSelected: (index) => _controller.animateToPage(index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn),
            ),
          Flexible(
            child: PageView.builder(
              controller: _controller,
              itemBuilder: (context, index) => [
                const HomeScreen(),
                const SizedBox(child: Text("It's so cold outside.")),
                const SizedBox(child: Text("It's so cold outside."))
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
            color: Colors.grey[900]!,
          ),
          child: SalomonBottomBar(
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            items: [
              SalomonBottomBarItem(
                title: const Text("Home"),
                icon: const Icon(Ionicons.home),
              ),
              SalomonBottomBarItem(
                title: const Text("Downloads"),
                icon: const Icon(Ionicons.download_outline),
              ),
              SalomonBottomBarItem(
                title: const Text("Settings"),
                icon: const Icon(Ionicons.settings_sharp),
              ),
            ],
            currentIndex: _currentIndex.value,
            onTap: (index) => _controller.animateToPage(index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn),
          ),
        ),
      ),
    );
  }
}

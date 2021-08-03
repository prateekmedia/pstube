import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/utils/utils.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900]!,
        title: Hero(
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
                  borderSide: BorderSide(color: Colors.grey[800]!, width: 0.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Colors.grey[700]!, width: 0.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Colors.grey[800]!, width: 0.0),
                ),
                filled: true,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Ionicons.person_outline),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemBuilder: (context, index) => [
          const HomeScreen(),
          const SizedBox(child: Text("It's so cold outside.")),
          const SizedBox(child: Text("It's so cold outside."))
        ][index],
        onPageChanged: (index) => _currentIndex.value = index,
        itemCount: 3,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
        padding: const EdgeInsets.all(6),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: Colors.grey[900]!,
        ),
        child: GNav(
          rippleColor: Colors.grey[300]!,
          hoverColor: Colors.grey[100]!,
          gap: 8,
          activeColor: Colors.white,
          iconSize: 24,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Theme.of(context).primaryColor,
          color: Colors.grey,
          tabs: const [
            GButton(
              text: "Home",
              icon: Ionicons.home,
            ),
            GButton(
              text: "Downloads",
              icon: Ionicons.download_outline,
            ),
            GButton(
              text: "Settings",
              icon: Ionicons.settings_sharp,
            ),
          ],
          selectedIndex: _currentIndex.value,
          onTabChange: (index) => _controller.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn),
        ),
      ),
    );
  }
}

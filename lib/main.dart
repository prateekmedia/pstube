import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search",
            isDense: true,
            prefixIcon: Icon(
              MdiIcons.magnify,
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
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(MdiIcons.account),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemBuilder: (context, index) => [
          HomeScreen(),
          Container(child: Text("It's so cold outside.")),
          Container(child: Text("It's so cold outside."))
        ][index],
        onPageChanged: (index) => _currentIndex.value = index,
        itemCount: 3,
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(4, 0, 4, 4),
        padding: EdgeInsets.all(6),
        decoration: ShapeDecoration(
          shape: StadiumBorder(),
          color: Colors.grey[900]!,
        ),
        child: GNav(
          rippleColor: Colors.grey[300]!,
          hoverColor: Colors.grey[100]!,
          gap: 8,
          activeColor: Colors.white,
          iconSize: 24,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: Duration(milliseconds: 400),
          tabBackgroundColor: Theme.of(context).primaryColor,
          color: Colors.grey,
          tabs: [
            GButton(
              text: "Home",
              icon: MdiIcons.home,
            ),
            GButton(
              text: "Downloads",
              icon: MdiIcons.download,
            ),
            GButton(
              text: "Settings",
              icon: MdiIcons.cog,
            ),
          ],
          selectedIndex: _currentIndex.value,
          onTabChange: (index) => _controller.animateToPage(index,
              duration: Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn),
        ),
      ),
    );
  }
}

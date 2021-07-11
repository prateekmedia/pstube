import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900]!,
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search now",
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
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(4),
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
              icon: MdiIcons.homeOutline,
            ),
            GButton(
              text: "Downloads",
              icon: MdiIcons.downloadOutline,
            ),
            GButton(
              text: "Settings",
              icon: MdiIcons.cogOutline,
            ),
          ],
          selectedIndex: _currentIndex,
          onTabChange: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

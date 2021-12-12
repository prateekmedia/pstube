import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutube/utils/utils.dart';
import 'package:flutube/models/models.dart';

const mobileWidth = 800;
const primaryColor = Colors.red;

ThemeData getThemeData(BuildContext context, Brightness brightness) {
  return ThemeData(
    primarySwatch: primaryColor,
    primaryColor: primaryColor,
    fontFamily: 'Roboto',
    colorScheme: brightness.isDark
        ? const ColorScheme.dark().copyWith(
            surface: primaryColor.brighten(8),
            primary: primaryColor.brighten(8),
            secondary: primaryColor.brighten(8),
          )
        : ColorScheme.fromSwatch(
            brightness: brightness,
            primarySwatch: primaryColor,
          ),
    textTheme: brightness.textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: brightness.getAltBackgroundColor,
      foregroundColor: brightness.textColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        systemNavigationBarColor: brightness.getBackgroundColor,
        statusBarColor: brightness.getBackgroundColor,
        statusBarIconBrightness: brightness.reverse,
        statusBarBrightness: brightness.reverse,
      ),
      titleTextStyle: brightness.textTheme.headline3,
    ),
    indicatorColor: primaryColor,
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: brightness.getAltBackgroundColor,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );
}

final myApp = FTInfo(
  name: 'FluTube',
  url: 'https://github.com/prateekmedia/flutube',
  description: 'Youtube client made using flutter.',
  image: "flutube.png",
);

final developerInfos = <FTInfo>[
  FTInfo(
    name: 'Prateek SU',
    url: 'https://github.com/prateekmedia',
    description:
        'Founder | Lead Developer | Always curious to learn new and great stuff',
    image: "prateekmedia.jpg",
  )
];

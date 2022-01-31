import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutube/utils/utils.dart';

ThemeData getThemeData(BuildContext context, Brightness brightness) {
  return ThemeData(
    primarySwatch: primaryColor,
    primaryColor: primaryColor,
    fontFamily: 'NotoSans',
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
    tabBarTheme: TabBarTheme(labelColor: brightness.textTheme.bodyText1!.color),
    appBarTheme: AppBarTheme(
      backgroundColor: brightness.isDark ? Colors.grey[850]! : Colors.grey[50]!,
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

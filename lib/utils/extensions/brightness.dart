import 'package:flutter/material.dart';

extension BrightnessExtensions on Brightness {
  bool get isDark => this == Brightness.dark;

  Brightness get reverse => isDark ? Brightness.light : Brightness.dark;

  Color get textColor => isDark ? Colors.white : Colors.black;
  Color get textColor2 => isDark ? Colors.white70 : Colors.black87;

  Color get getBackgroundColor =>
      isDark ? Colors.grey[800]! : Colors.grey[200]!;
  Color get getAltBackgroundColor =>
      isDark ? Colors.grey[900]! : Colors.grey[300]!;
  Color get getAlt2BackgroundColor =>
      isDark ? Colors.grey[400]! : Colors.grey[600]!;
}

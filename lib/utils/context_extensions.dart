import 'package:flutter/material.dart';
import 'package:flutube/utils/constants.dart';

extension ContextExtensions on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ThemeData get theme => Theme.of(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  back([VoidCallback? after]) {
    if (after != null) after();
    Navigator.of(this).pop();
  }

  pushPage(Widget page) => Navigator.of(this).push(MaterialPageRoute(builder: (ctx) => page));

  Color get getBackgroundColor => isDark ? Colors.grey[800]! : Colors.grey[200]!;
  Color get getAltBackgroundColor => isDark ? Colors.grey[900]! : Colors.grey[300]!;
  Color get getAlt2BackgroundColor => isDark ? Colors.grey[400]! : Colors.grey[600]!;

  bool get isMobile => !isLandscape && width < mobileWidth;

  MediaQueryData get queryData => MediaQuery.of(this);
  get isLandscape => queryData.orientation == Orientation.landscape;
  get width => queryData.size.width;
  get height => queryData.size.height;
}

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

  bool get isMobile => width < mobileWidth;

  get queryData => MediaQuery.of(this);
  get width => queryData.size.width;
  get height => queryData.size.height;
}

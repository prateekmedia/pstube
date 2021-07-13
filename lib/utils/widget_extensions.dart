import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  centerHorizontally() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [this],
      );
  center() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [this],
        ),
      );
}

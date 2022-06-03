import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  Column centerHorizontally() => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [this],
      );
  Widget center({bool center = true}) => center
      ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [this],
          ),
        )
      : this;
}

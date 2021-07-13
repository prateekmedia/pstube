import 'package:flutter/cupertino.dart';

buildColumnOrRow(bool isRow, {required List<Widget> children}) {
  return isRow
      ? Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        )
      : Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
}

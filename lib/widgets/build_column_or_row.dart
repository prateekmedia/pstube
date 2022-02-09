import 'package:flutter/cupertino.dart';

Flex buildColumnOrRow({required bool isRow, required List<Widget> children}) {
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

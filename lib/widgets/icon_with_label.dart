import 'package:flutter/material.dart';

enum SecColor { dark, light }

Widget iconWithLabel(
  String label, {
  SecColor secColor = SecColor.light,
  double spacing = 2,
  TextStyle? style,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: spacing),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(secColor == SecColor.light ? 0.18 : 1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: style,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

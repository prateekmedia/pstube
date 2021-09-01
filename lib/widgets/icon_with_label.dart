import 'package:flutter/material.dart';

enum SecColor { dark, light }

Widget iconWithLabel(
  String label, {
  TextStyle? style,
  SecColor secColor = SecColor.light,
  EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 2),
}) {
  return Container(
    margin: margin,
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

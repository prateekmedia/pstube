import 'package:flutter/material.dart';

enum SecColor { dark, light }

Widget secLabel({
  required String label,
  SecColor secColor = SecColor.light,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 2),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(secColor == SecColor.light ? 0.18 : 1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(label),
  );
}

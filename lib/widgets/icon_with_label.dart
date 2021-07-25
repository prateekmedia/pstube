import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

enum SecColor { dark, light }

Widget iconWithLabel(
  String label, {
  SecColor secColor = SecColor.light,
  TextStyle? style,
  bool enabled = false,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 2),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(secColor == SecColor.light ? 0.18 : 1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: enabled
        ? Shimmer.fromColors(
            baseColor: Colors.grey[900]!,
            highlightColor: Colors.grey[800]!,
            child: Text(label, style: style))
        : Text(label, style: style),
  );
}

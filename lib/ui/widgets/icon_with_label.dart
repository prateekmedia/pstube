import 'package:flutter/material.dart';
import 'package:pstube/data/extensions/extensions.dart';

enum SecColor { dark, light }

class IconWithLabel extends StatelessWidget {
  const IconWithLabel({
    super.key,
    required this.label,
    this.style,
    this.margin = const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    this.secColor = SecColor.light,
  });

  final String label;
  final TextStyle? style;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final SecColor secColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: context.getBackgroundColor.brighten(
          context,
          secColor == SecColor.light ? 20 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: style,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

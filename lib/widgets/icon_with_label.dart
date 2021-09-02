import 'package:flutter/material.dart';
import '../utils/utils.dart';

enum SecColor { dark, light }

class IconWithLabel extends StatelessWidget {
  final String label;
  final TextStyle? style;
  final EdgeInsets margin;
  final SecColor secColor;

  const IconWithLabel({
    Key? key,
    required this.label,
    this.style,
    this.margin = const EdgeInsets.symmetric(horizontal: 2),
    this.secColor = SecColor.light,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[context.isDark ? 900 : 300]!
            .withOpacity(secColor == SecColor.light ? 0.18 : 1),
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

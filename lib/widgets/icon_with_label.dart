import 'package:flutter/material.dart';
import 'package:flutube/utils/utils.dart';

enum SecColor { dark, light }

class IconWithLabel extends StatelessWidget {
  const IconWithLabel({
    Key? key,
    required this.label,
    this.style,
    this.margin = const EdgeInsets.symmetric(horizontal: 2),
    this.secColor = SecColor.light,
  }) : super(key: key);

  final String label;
  final TextStyle? style;
  final EdgeInsets margin;
  final SecColor secColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.getAltBackgroundColor
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

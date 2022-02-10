import 'package:flutter/material.dart';
import 'package:flutube/utils/utils.dart';

enum SecColor { dark, light }

class IconWithLabel extends StatelessWidget {
  const IconWithLabel({
    Key? key,
    required this.label,
    this.style,
    this.margin = const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: context.getBackgroundColor
            .brighten(context, secColor == SecColor.light ? 20 : 1),
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

import 'package:flutter/material.dart';
import 'package:pstube/data/extensions/extensions.dart';

class DescriptionInfoWidget extends StatelessWidget {
  const DescriptionInfoWidget({
    Key? key,
    required this.title,
    required this.body,
  }) : super(key: key);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: context.textTheme.headline3,
        ),
        Text(body),
      ],
    );
  }
}

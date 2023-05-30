import 'package:flutter/material.dart';
import 'package:pstube/foundation/extensions/extensions.dart';

class DescriptionInfoWidget extends StatelessWidget {
  const DescriptionInfoWidget({
    required this.title,
    required this.body,
    super.key,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: context.textTheme.displaySmall,
        ),
        Text(body),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';

Widget iconWithBottomLabel({
  required IconData icon,
  VoidCallback? onPressed,
  required String label,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      children: [
        AdwButton.circular(
          size: 40,
          onPressed: onPressed ?? () {},
          child: Icon(icon),
        ),
        const SizedBox(height: 2),
        Text(label),
      ],
    ),
  );
}

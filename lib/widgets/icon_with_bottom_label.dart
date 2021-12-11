import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget iconWithBottomLabel({
  required IconData icon,
  VoidCallback? onPressed,
  required String label,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      children: [
        IconButton(
          icon: FaIcon(icon, size: 28),
          onPressed: onPressed ?? () {},
        ),
        const SizedBox(height: 2),
        Text(label),
      ],
    ),
  );
}

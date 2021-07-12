import 'package:flutter/material.dart';

Widget iconWithLabel({
  required IconData icon,
  required String label,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 2),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.18),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          size: 20,
        ),
        SizedBox(width: 10),
        Text(label),
      ],
    ),
  );
}

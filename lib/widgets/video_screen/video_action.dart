import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';

class VideoAction extends StatelessWidget {
  const VideoAction({
    Key? key,
    required this.icon,
    this.onPressed,
    required this.label,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
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
}

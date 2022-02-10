import 'package:flutter/material.dart';

class SFInfo {
  SFInfo({
    required this.name,
    required this.url,
    required this.description,
    this.image,
  });

  final String name;
  final String url;
  final String description;
  final String? image;
}

extension CoolSFInfoExtensions on SFInfo {
  Widget get imageWidget => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image.asset(
            'assets/$image',
            width: 135,
          ),
        ),
      );
}

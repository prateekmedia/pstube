import 'package:flutter/material.dart';

class FTInfo {
  FTInfo({
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

extension CoolFtInfoExtensions on FTInfo {
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

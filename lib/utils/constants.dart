import 'package:flutter/material.dart';
import 'package:flutube/models/models.dart';

const mobileWidth = 800;
const primaryColor = Colors.red;

final myApp = FTInfo(
  name: 'FluTube',
  url: 'https://github.com/prateekmedia/flutube',
  description: 'Youtube client made using flutter.',
  image: 'flutube.png',
);

final developerInfos = <FTInfo>[
  FTInfo(
    name: 'Prateek Sunal',
    url: 'https://github.com/prateekmedia',
    description: 'Founder | Lead Developer',
    image: 'prateekmedia.jpeg',
  )
];

final translatorsInfos = <FTInfo>[
  FTInfo(
    name: 'Prateek Sunal',
    url: 'https://github.com/prateekmedia',
    description: 'Hindi Translations',
  )
];

import 'package:flutter/material.dart';
import 'package:sftube/models/sf_info.dart';
export 'package:sftube/models/sf_info.dart';

const mobileWidth = 800;
const primaryColor = Colors.red;

final myApp = SFInfo(
  name: 'SFTube',
  url: 'https://github.com/prateekmedia/sftube',
  description: 'Youtube client made using flutter.',
  image: 'sftube.png',
);

final developerInfos = <SFInfo>[
  SFInfo(
    name: 'Prateek Sunal',
    url: 'https://github.com/prateekmedia',
    description: 'Founder | Lead Developer',
    image: 'prateekmedia.jpeg',
  )
];

final translatorsInfos = <SFInfo>[
  SFInfo(
    name: 'Prateek Sunal',
    url: 'https://github.com/prateekmedia',
    description: 'Hindi Translations',
  )
];

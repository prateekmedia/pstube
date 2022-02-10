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

List<SFInfo> developerInfos = <SFInfo>[
  SFInfo(
    name: 'Prateek Sunal',
    url: 'https://github.com/prateekmedia',
    description: 'Founder | Lead Developer',
    image: 'prateekmedia.jpeg',
  )
];

List<SFInfo> translatorsInfos = <SFInfo>[
  SFInfo(
    name: 'MesterPerfect',
    url: 'https://github.com/MesterPerfect',
    description: 'Arabic',
  ),
  SFInfo(
    name: 'albanobattistella',
    url: 'https://github.com/albanobattistella',
    description: 'Italian',
  ),
  SFInfo(
    name: 'Allan Nordhøy',
    url: 'https://github.com/comradekingu',
    description: 'Norwegian Bokmål',
  ),
];

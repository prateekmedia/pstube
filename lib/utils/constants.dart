import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pstube/models/sf_info.dart';
export 'package:pstube/models/sf_info.dart';

const mobileWidth = 800;
const primaryColor = Colors.red;
final videoPlatforms = kIsWeb || Platform.isAndroid || Platform.isIOS;

const ytCom = 'https://youtube.com';

final myApp = SFInfo(
  name: 'PsTube',
  nickname: 'pstube',
  url: 'https://github.com/prateekmedia/pstube',
  description: 'Youtube client made using flutter.',
  image: 'pstube.png',
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

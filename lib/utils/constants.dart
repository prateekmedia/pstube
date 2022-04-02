import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pstube/models/ps_info.dart';
export 'package:pstube/models/ps_info.dart';

const mobileWidth = 800;
const primaryColor = Colors.red;
final mobVideoPlatforms = kIsWeb || Platform.isAndroid || Platform.isIOS;

const ytCom = 'https://youtube.com';

final myApp = SFInfo(
  name: 'PsTube',
  nickname: 'pstube',
  url: 'https://github.com/prateekmedia/pstube',
  description: 'Watch and download videos without ads',
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
  SFInfo(
    name: 'Hari',
    url: 'https://github.com/hari-python',
    description: 'Malayalam',
  ),
  SFInfo(
    name: 'ptrarian',
    url: 'https://github.com/ptrarian',
    description: 'Indonesian',
  ),
  SFInfo(
    name: 'Kemal Oktay',
    url: 'https://github.com/oktay454',
    description: 'Turkish',
  ),
];

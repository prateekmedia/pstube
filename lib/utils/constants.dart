import 'package:flutter/material.dart';
import 'package:flutube/models/models.dart';

const mobileWidth = 800;
const primaryColor = Colors.red;

final myApp = FTInfo(
  name: 'FluTube',
  url: 'https://github.com/prateekmedia/flutube',
  description: 'Youtube client made using flutter.',
  image: "flutube.png",
);

final developerInfos = <FTInfo>[
  FTInfo(
    name: 'Prateek SU',
    url: 'https://github.com/prateekmedia',
    description:
        'Founder | Lead Developer | Always curious to learn new and great stuff',
    image: "prateekmedia.jpeg",
  )
];

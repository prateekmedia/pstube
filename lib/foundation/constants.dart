import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
export 'package:pstube/data/models/ps_info.dart';

class Constants {
  static const mobileWidth = 800;
  static const primaryColor = Colors.red;
  static final mobVideoPlatforms =
      kIsWeb || Platform.isAndroid || Platform.isIOS;

  static const ytCom = 'https://youtube.com';
}

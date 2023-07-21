import 'dart:math';

import 'package:intl/intl.dart';

extension IntExtension on int {
  String get addCommas => NumberFormat('###,###', 'en_US').format(this);

  String get formatNumber => NumberFormat.compact().format(this);

  String getFileSize({int decimals = 1}) {
    if (this <= 0) return '';
    final suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    final i = (log(this) / log(1024)).floor();
    return '${(this / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  String getBitrate({int decimals = 0}) =>
      '${getFileSize(decimals: decimals)}PS';
}

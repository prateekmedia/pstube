import 'package:intl/intl.dart';

extension IntExtension on int {
  get formatNumber => NumberFormat.compact().format(this);
}

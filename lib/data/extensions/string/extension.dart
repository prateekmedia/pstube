import 'package:url_launcher/url_launcher.dart';

extension UrlLauncher on String {
  Future<bool> launchIt() async => launchUrl(Uri.parse(this));

  Duration parseDuration() {
    var hours = 0;
    var minutes = 0;
    int micros;
    final parts = split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }
}

extension NullableExtension on String? {
  bool get isNullOrWhiteSpace {
    if (this == null) {
      return true;
    }
    if (this!.trim().isEmpty) {
      return true;
    }
    return false;
  }
}

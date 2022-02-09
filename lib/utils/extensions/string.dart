import 'package:url_launcher/url_launcher.dart' as url_launcher;

extension UrlLauncher on String {
  Future<bool> launchIt() async => url_launcher.launch(this);

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

import 'package:url_launcher/url_launcher.dart';

extension UrlLauncher on String {
  launchIt() async => await canLaunch(this) ? await launch(this) : throw 'Could not launch $this';

  Duration parseDuration() {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = split(':');
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

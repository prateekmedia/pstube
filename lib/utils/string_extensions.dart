import 'package:url_launcher/url_launcher.dart';

extension UrlLauncher on String {
  launchIt() async => await canLaunch(this) ? await launch(this) : throw 'Could not launch $this';
}

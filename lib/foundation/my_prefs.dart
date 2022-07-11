import 'package:shared_preferences/shared_preferences.dart';

final prefs = MyPrefs().prefs;

class MyPrefs {
  factory MyPrefs() {
    return _instance;
  }

  MyPrefs._internal();

  static final MyPrefs _instance = MyPrefs._internal();

  late SharedPreferences _kPrefs;

  Future<void> init() async {
    _kPrefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _kPrefs;
}

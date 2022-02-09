import 'package:shared_preferences/shared_preferences.dart';

final prefs = MyPrefs().prefs;

class MyPrefs {
  factory MyPrefs() {
    return _instance;
  }

  MyPrefs._internal();

  static final MyPrefs _instance = MyPrefs._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _prefs;
}

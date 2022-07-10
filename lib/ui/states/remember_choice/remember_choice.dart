import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/data/services/my_prefs.dart';

class RememberChoiceNotifier extends StateNotifier<bool> {
  RememberChoiceNotifier({required bool state}) : super(state);

  set value(bool newChoice) {
    state = newChoice;
    MyPrefs().prefs.setBool('remember_choice', state);
  }

  void toggle() {
    state = !state;
    MyPrefs().prefs.setBool('remember_choice', state);
  }

  void reset() {
    MyPrefs().prefs.remove('remember_choice').whenComplete(() => state = false);
  }
}

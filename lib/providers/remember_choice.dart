import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/utils/shared_prefs.dart';

final rememberChoiceProvider =
    StateNotifierProvider<RememberChoiceNotifier, bool>(
  (_) =>
      RememberChoiceNotifier(state: prefs.getBool('remember_choice') ?? false),
);

class RememberChoiceNotifier extends StateNotifier<bool> {
  RememberChoiceNotifier({required bool state}) : super(state);

  set value(bool newChoice) {
    state = newChoice;
    MyPrefs().prefs.setBool('remember_choice', state);
  }

  void reset() {
    MyPrefs().prefs.remove('remember_choice').whenComplete(() => state = false);
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/data/services/my_prefs.dart';

class ThemeTypeNotifier extends StateNotifier<ThemeMode> {
  ThemeTypeNotifier(ThemeMode state) : super(state);

  set themeType(int newThemeType) {
    state =
        ThemeMode.values.firstWhere((element) => element.index == newThemeType);
    MyPrefs().prefs.setInt('themeType', state.index);
  }

  set toggle(bool value) => themeType = value ? 2 : 1;

  void reset() {
    MyPrefs()
        .prefs
        .remove('themeType')
        .whenComplete(() => state = ThemeMode.system);
  }
}

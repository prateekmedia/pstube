import 'package:flutter/material.dart';
import 'package:flutube/utils/shared_prefs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final themeTypeProvider = StateNotifierProvider<ThemeTypeNotifier, ThemeMode>(
  (_) => ThemeTypeNotifier(
    ThemeMode.values
        .firstWhere((element) => element.index == MyPrefs().prefs.getInt('themeType'), orElse: () => ThemeMode.system),
  ),
);

class ThemeTypeNotifier extends StateNotifier<ThemeMode> {
  ThemeTypeNotifier(state) : super(state);

  set themeType(int newThemeType) {
    state = ThemeMode.values.firstWhere((element) => element.index == newThemeType);
    MyPrefs().prefs.setInt('themeType', state.index);
  }

  reset() {
    MyPrefs().prefs.remove('themeType').whenComplete(() => state = ThemeMode.system);
  }
}

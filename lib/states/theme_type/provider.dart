import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pstube/foundation/services.dart';
import 'package:pstube/states/theme_type/theme_type.dart';

final themeTypeProvider = StateNotifierProvider<ThemeTypeNotifier, ThemeMode>(
  (_) => ThemeTypeNotifier(
    ThemeMode.values.firstWhere(
      (element) => element.index == MyPrefs().prefs.getInt('themeType'),
      orElse: () => ThemeMode.system,
    ),
  ),
);

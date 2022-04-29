import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/utils/shared_prefs.dart';

final regionProvider = StateNotifierProvider<RegionNotifier, Regions>(
  (_) => RegionNotifier(
    Regions.values.firstWhere(
      (p0) => prefs.getString('region') != null
          ? p0.name == prefs.getString('region')
          : p0.name == WidgetsBinding.instance.window.locale.countryCode,
      orElse: () => Regions.US,
    ),
  ),
);

class RegionNotifier extends StateNotifier<Regions> {
  RegionNotifier(Regions state) : super(state);

  set region(Regions newRegion) {
    state = Regions.values.firstWhere((element) => element == newRegion);
    MyPrefs().prefs.setString('region', state.name);
  }

  void reset() {
    MyPrefs().prefs.remove('region').whenComplete(
          () => state = Regions.values.firstWhere(
            (e) => e.name == WidgetsBinding.instance.window.locale.countryCode,
            orElse: () => Regions.US,
          ),
        );
  }
}

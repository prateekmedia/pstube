import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/foundation/my_prefs.dart';

class RegionNotifier extends StateNotifier<Regions> {
  RegionNotifier(super.state);

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

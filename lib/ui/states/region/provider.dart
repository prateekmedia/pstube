import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/services/my_prefs.dart';
import 'package:pstube/ui/states/region/region.dart';

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

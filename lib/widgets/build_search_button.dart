import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:lucide_icons/lucide_icons.dart';

Widget buildSearchButton(BuildContext context) {
  return IconButton(
    onPressed: () => showSearch(context: context, delegate: CustomSearchDelegate()),
    icon: const Icon(LucideIcons.search, size: 20),
  );
}

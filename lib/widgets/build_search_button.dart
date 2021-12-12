import 'package:flutter/material.dart';
import 'package:ant_icons/ant_icons.dart';
import 'package:flutube/screens/screens.dart';

Widget buildSearchButton(BuildContext context) {
  return IconButton(
    onPressed: () =>
        showSearch(context: context, delegate: CustomSearchDelegate()),
    icon: const Icon(AntIcons.search_outline, size: 20),
  );
}

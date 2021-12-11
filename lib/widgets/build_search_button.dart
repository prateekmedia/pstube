import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget buildSearchButton(BuildContext context) {
  return IconButton(
    onPressed: () =>
        showSearch(context: context, delegate: CustomSearchDelegate()),
    icon: const FaIcon(FontAwesomeIcons.search, size: 20),
  );
}

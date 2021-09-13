import 'package:flutter/material.dart';
import 'package:flutube/utils/utils.dart';

Widget getCircularProgressIndicator() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 25),
    child: const CircularProgressIndicator().center(),
  );
}

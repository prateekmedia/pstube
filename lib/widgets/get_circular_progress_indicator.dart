import 'package:flutter/material.dart';
import 'package:sftube/utils/utils.dart';

Widget getCircularProgressIndicator({bool center = true}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 25),
    child: const CircularProgressIndicator().center(center: center),
  );
}

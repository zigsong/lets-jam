import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

SnackBar customSnackbar(String text) {
  return SnackBar(
    content: Text(text),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    backgroundColor: ColorSeed.organizedBlackLight.color,
  );
}

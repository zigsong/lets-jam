import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

/// 스텝 공통 타이틀.
class StepTitle extends StatelessWidget {
  final String text;
  const StepTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: ColorSeed.organizedBlackMedium.color,
      ),
    );
  }
}

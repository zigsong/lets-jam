import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class UtilButton extends StatelessWidget {
  final String text;
  final Function() onPressed;

  const UtilButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11.5, vertical: 6.5),
        decoration: BoxDecoration(
          border: Border.all(color: ColorSeed.joyfulYellowLight.color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(color: ColorSeed.joyfulYellowLight.color),
        ),
      ),
    );
  }
}

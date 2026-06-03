import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class WideButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool disabled;

  const WideButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: disabled
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ColorSeed.boldOrangeStrong.color.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: ColorSeed.boldOrangeStrong.color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: ColorSeed.meticulousGrayLight.color,
          disabledForegroundColor: ColorSeed.meticulousGrayMedium.color,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class WideButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool disabled;
  final bool isLoading;

  const WideButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.disabled = false,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || isLoading;

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: isDisabled
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
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: ColorSeed.boldOrangeStrong.color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isLoading
              ? ColorSeed.boldOrangeStrong.color
              : ColorSeed.meticulousGrayLight.color,
          disabledForegroundColor:
              isLoading ? Colors.white : ColorSeed.meticulousGrayMedium.color,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
      ),
    );
  }
}

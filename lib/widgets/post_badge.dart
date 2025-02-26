import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class PostBadge extends StatelessWidget {
  final String text;

  const PostBadge({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4.5),
      decoration: BoxDecoration(
          color: ColorSeed.boldOrangeLight.color,
          borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1,
            color: ColorSeed.boldOrangeMedium.color),
      ),
    );
  }
}

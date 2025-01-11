import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

enum TagSizeEnum { small, medium }

class Tag extends StatelessWidget {
  final String text;
  final TagSizeEnum? size;
  final Color? fgColor;
  final Color? bgColor;

  const Tag(
      {super.key,
      required this.text,
      this.size = TagSizeEnum.medium,
      this.fgColor,
      this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size == TagSizeEnum.small ? 8 : 12,
          vertical: size == TagSizeEnum.small ? 2 : 4),
      decoration: BoxDecoration(
          color: bgColor ?? ColorSeed.boldOrangeStrong.color,
          borderRadius: BorderRadius.circular(25)),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
              fontSize: size == TagSizeEnum.small ? 12 : 14,
              fontWeight: FontWeight.w500,
              color: fgColor ?? Colors.white),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

enum TagSizeEnum { small, medium }

class Tag extends StatelessWidget {
  final String text;
  final TagSizeEnum? size;
  final Color? fgColor;
  final Color? bgColor;
  final BoxBorder? border;

  const Tag(
      {super.key,
      required this.text,
      this.size = TagSizeEnum.medium,
      this.fgColor,
      this.bgColor,
      this.border});

  bool get isSmall => size == TagSizeEnum.small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 6 : 8, vertical: isSmall ? 1 : 4),
      decoration: BoxDecoration(
          color: bgColor ?? ColorSeed.boldOrangeStrong.color,
          border: border,
          borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(
            fontSize: isSmall ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: fgColor ?? Colors.white,
            height: 1.54),
      ),
    );
  }
}

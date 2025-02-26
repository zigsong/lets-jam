import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

enum TagSizeEnum { small, medium }

enum TagColorEnum { orange, black }

class Tag extends StatelessWidget {
  final String text;
  final TagColorEnum color;
  final TagSizeEnum size;
  final bool selected;

  const Tag(
      {super.key,
      required this.text,
      required this.color,
      this.size = TagSizeEnum.medium,
      this.selected = false});

  @override
  Widget build(BuildContext context) {
    if (color == TagColorEnum.orange) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
        decoration: BoxDecoration(
            color: selected == true ? ColorSeed.boldOrangeMedium.color : null,
            border: selected == true
                ? null
                : Border.all(color: ColorSeed.boldOrangeMedium.color, width: 2),
            borderRadius: BorderRadius.circular(20)),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1,
              color: selected == true
                  ? Colors.white
                  : ColorSeed.boldOrangeMedium.color),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
          color: selected == true ? ColorSeed.organizedBlackMedium.color : null,
          border: selected == true
              ? null
              : Border.all(
                  color: ColorSeed.meticulousGrayMedium.color, width: 1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1,
            color: selected == true
                ? Colors.white
                : ColorSeed.organizedBlackMedium.color),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

enum TagSizeEnum { small, medium }

enum TagColorEnum { orange, black }

class Tag extends StatelessWidget {
  final String text;
  final TagColorEnum color;
  final TagSizeEnum size;
  final bool withXIcon;
  final bool? selected;
  final void Function()? onToggle;

  const Tag({
    super.key,
    required this.text,
    required this.color,
    this.size = TagSizeEnum.medium,
    this.withXIcon = false,
    this.selected = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (color == TagColorEnum.orange) {
      return GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: selected == true ? 16 : 12,
              vertical: selected == true ? 8.5 : 4.5),
          decoration: BoxDecoration(
              color: selected == true ? ColorSeed.boldOrangeMedium.color : null,
              border: selected == true
                  ? null
                  : Border.all(
                      color: ColorSeed.boldOrangeMedium.color, width: 2),
              borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Text(
                text,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    color: selected == true
                        ? Colors.white
                        : ColorSeed.boldOrangeMedium.color),
              ),
              if (withXIcon == true)
                Row(
                  children: [
                    const SizedBox(
                      width: 8,
                    ),
                    Icon(
                      Icons.close,
                      size: 16,
                      color: selected == true
                          ? Colors.white
                          : ColorSeed.boldOrangeRegular.color,
                    )
                  ],
                )
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: selected == true ? 16 : 14,
            vertical: selected == true ? 6 : 4),
        decoration: BoxDecoration(
            color:
                selected == true ? ColorSeed.organizedBlackMedium.color : null,
            border: selected == true
                ? null
                : Border.all(
                    color: ColorSeed.meticulousGrayLight.color, width: 1),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1,
                  color: selected == true
                      ? Colors.white
                      : ColorSeed.organizedBlackMedium.color),
            ),
            if (withXIcon == true)
              Row(
                children: [
                  const SizedBox(
                    width: 8,
                  ),
                  Icon(
                    Icons.close,
                    size: 16,
                    color: selected == true
                        ? Colors.white
                        : ColorSeed.boldOrangeRegular.color,
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}

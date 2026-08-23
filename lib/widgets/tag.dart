import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

enum TagColorEnum { orange, black }

/// 태그 위젯. Figma JAM_design 기준 4가지 디자인으로 통일한다.
/// - orange + selected  : 오렌지 채움 (bg Orange/800, 흰 글씨)
/// - orange + !selected : 오렌지 아웃라인 (border Orange/800, 오렌지 글씨)
/// - black  + selected  : 블랙 채움 (bg Black/800, 흰 글씨)
/// - black  + !selected : 그레이 아웃라인 (border Gray/200, 검정 글씨)
class Tag extends StatelessWidget {
  final String text;
  final TagColorEnum color;
  final bool withXIcon;
  final bool selected;
  final void Function()? onToggle;

  const Tag({
    super.key,
    required this.text,
    required this.color,
    this.withXIcon = false,
    this.selected = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final _TagStyle style = _resolveStyle();

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7.5),
        decoration: BoxDecoration(
          color: style.background,
          border: Border.all(color: style.border, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1,
                color: style.foreground,
              ),
            ),
            if (withXIcon) ...[
              const SizedBox(width: 8),
              Icon(Icons.close, size: 12, color: style.icon),
            ],
          ],
        ),
      ),
    );
  }

  _TagStyle _resolveStyle() {
    switch (color) {
      case TagColorEnum.orange:
        return selected
            ? _TagStyle(
                background: ColorSeed.boldOrangeStrong.color,
                border: ColorSeed.boldOrangeStrong.color,
                foreground: Colors.white,
                icon: Colors.white,
              )
            : _TagStyle(
                background: Colors.transparent,
                border: ColorSeed.boldOrangeStrong.color,
                foreground: ColorSeed.boldOrangeStrong.color,
                icon: ColorSeed.boldOrangeRegular.color,
              );
      case TagColorEnum.black:
        return selected
            ? _TagStyle(
                background: ColorSeed.organizedBlackMedium.color,
                border: ColorSeed.organizedBlackMedium.color,
                foreground: Colors.white,
                icon: Colors.white,
              )
            : _TagStyle(
                background: Colors.transparent,
                border: ColorSeed.meticulousGrayLight.color,
                foreground: ColorSeed.organizedBlackMedium.color,
                icon: ColorSeed.meticulousGrayMedium.color,
              );
    }
  }
}

class _TagStyle {
  final Color background;
  final Color border;
  final Color foreground;
  final Color icon;

  const _TagStyle({
    required this.background,
    required this.border,
    required this.foreground,
    required this.icon,
  });
}

import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

enum LikeButtonSize {
  sm(24, 4),
  md(30, 6),
  lg(40, 8);

  final double length;
  final double padding;

  const LikeButtonSize(this.length, this.padding);
}

/// 찜/좋아요 표시용 버튼. 상태와 토글 로직은 사용처에서 관리한다.
class LikeButton extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onTap;
  final LikeButtonSize? size;
  final bool? hasBackground;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.size,
    this.hasBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? LikeButtonSize.lg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize.length,
        height: buttonSize.length,
        padding: EdgeInsets.all(buttonSize.padding),
        decoration: hasBackground == true
            ? BoxDecoration(
                color: ColorSeed.organizedBlackMedium.color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6))
            : null,
        child: isLiked
            ? Image.asset('assets/images/like_filled.png')
            : Image.asset('assets/images/like_empty.png'),
      ),
    );
  }
}

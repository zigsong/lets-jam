import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class PostTypeBadge extends StatelessWidget {
  const PostTypeBadge({super.key, required this.postType});

  final PostTypeEnum postType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 2, 10, 2),
      decoration: BoxDecoration(
        color: postType == PostTypeEnum.findBand
            ? Colors.transparent
            : ColorSeed.boldOrangeStrong.color,
        border: postType == PostTypeEnum.findBand
            ? Border(
                top: BorderSide(color: ColorSeed.boldOrangeStrong.color),
                right: BorderSide(color: ColorSeed.boldOrangeStrong.color),
                bottom: BorderSide(color: ColorSeed.boldOrangeStrong.color),
              )
            : null,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Text(
        postType == PostTypeEnum.findBand ? '밴드' : '멤버',
        style: TextStyle(
            color: postType == PostTypeEnum.findBand
                ? ColorSeed.boldOrangeStrong.color
                : Colors.white),
      ),
    );
  }
}

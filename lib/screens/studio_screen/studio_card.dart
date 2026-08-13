import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_jam/screens/studio_screen/studio.dart';
import 'package:lets_jam/screens/studio_screen/studio_detail_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/like_button.dart';
import 'package:lets_jam/widgets/post_badge.dart';

/// 1000 단위 콤마. 22000 -> "22,000".
final _priceFormat = NumberFormat('#,###');

class StudioCard extends StatelessWidget {
  final Studio room;
  final bool liked;
  final VoidCallback onToggleLike;

  const StudioCard({
    super.key,
    required this.room,
    required this.liked,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StudioDetailScreen(
              studioId: room.id,
              studioName: room.name,
              initiallyLiked: liked,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(width: 1, color: ColorSeed.boldOrangeRegular.color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 정보
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  if (room.regionLabel != null) ...[
                    const SizedBox(height: 6),
                    PostBadge(text: room.regionLabel!),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        room.minPrice != null
                            ? '${_priceFormat.format(room.minPrice)}원~'
                            : '가격 문의',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ColorSeed.boldOrangeMedium.color,
                        ),
                      ),
                      if (room.roomCount > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '· 룸 ${room.roomCount}개',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // 하단 이미지 + 찜 버튼
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(11),
                  bottomRight: Radius.circular(11),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: ColorSeed.boldOrangeLight.color,
                      alignment: Alignment.center,
                      child: Text(
                        '사진을 준비중이에요',
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorSeed.organizedBlackLight.color,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: LikeButton(
                        isLiked: liked,
                        onTap: onToggleLike,
                        size: LikeButtonSize.md,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

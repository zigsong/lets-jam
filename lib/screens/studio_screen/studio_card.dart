import 'package:flutter/material.dart';
import 'package:lets_jam/screens/studio_screen/studio.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/post_badge.dart';

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
        // [프로토타입] 상세 화면은 아직 미구현
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${room.name} 상세는 준비 중이에요'),
            duration: const Duration(seconds: 1),
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
                  const SizedBox(height: 6),
                  PostBadge(text: room.district.displayName),
                  const SizedBox(height: 8),
                  Text(
                    room.tags.map((tag) => '#$tag').join('  '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorSeed.organizedBlackLight.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Color(0xffFFC02D)),
                      const SizedBox(width: 2),
                      Text(
                        '${room.rating} (${room.reviewCount})',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
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
                    if (room.imagePath != null)
                      Image.asset(room.imagePath!, fit: BoxFit.cover)
                    else
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
                      child: GestureDetector(
                        onTap: onToggleLike,
                        child: Image.asset(
                          liked
                              ? 'assets/images/like_filled.png'
                              : 'assets/images/like_empty.png',
                          width: 28,
                          height: 28,
                        ),
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

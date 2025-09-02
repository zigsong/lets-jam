import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class UploadTypeToggler extends StatelessWidget {
  final VoidCallback onTap;
  final int selectedIndex;

  const UploadTypeToggler(
      {super.key, required this.onTap, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double singleBarWidth = (screenWidth - 32) / 2;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ColorSeed.boldOrangeMedium.color,
                    ),
                  ),
                  child: ClipRRect(
                    // ClipRRect를 Stack 바로 위에 배치
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 100),
                          left: selectedIndex == 0 ? 0 : singleBarWidth,
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: singleBarWidth,
                            decoration: BoxDecoration(
                              color: ColorSeed.boldOrangeStrong.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              '멤버 구하기',
                              style: TextStyle(
                                color: selectedIndex == 0
                                    ? Colors.white
                                    : ColorSeed.boldOrangeStrong.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '밴드 구하기',
                              style: TextStyle(
                                color: selectedIndex == 0
                                    ? ColorSeed.boldOrangeStrong.color
                                    : Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          selectedIndex == 0
              ? '같이 합주할 멤버를 구해요. 작성한 글은 [밴드] 게시판에서 볼 수 있어요.'
              : '같이 합주할 밴드를 구해요. 작성한 글은 [멤버] 게시판에서 볼 수 있어요.',
          style:
              TextStyle(color: ColorSeed.boldOrangeMedium.color, fontSize: 11),
        )
      ],
    );
  }
}

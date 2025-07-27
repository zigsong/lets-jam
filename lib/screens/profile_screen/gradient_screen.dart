import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class GradientSplitScreen extends StatelessWidget {
  const GradientSplitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final halfHeight = screenHeight / 2 * 1.1;

    return Scaffold(
      body: Stack(
        children: [
          // 1. 검정색 하단 배경 (절반 높이)
          Positioned(
            top: halfHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(color: ColorSeed.organizedBlackMedium.color),
          ),

          // 2. 상단 이미지 (1:1 비율)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: halfHeight,
            child: Image.asset(
              'assets/images/asdf.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 3. 이미지 위에 검정색 그라데이션 덮기 (블렌딩 효과)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: halfHeight * 1.1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    ColorSeed.organizedBlackMedium.color,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

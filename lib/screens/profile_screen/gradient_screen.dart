import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class GradientSplitScreen extends StatelessWidget {
  final String? backgroundImageUrl;

  const GradientSplitScreen({super.key, this.backgroundImageUrl});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final halfHeight = screenHeight / 2 * 1.1;

    return Scaffold(
      backgroundColor: ColorSeed.organizedBlackMedium.color,
      body: Stack(
        children: [
          // 1. 상단 이미지
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: halfHeight,
            child: backgroundImageUrl != null && backgroundImageUrl!.isNotEmpty
                ? Image.network(
                    backgroundImageUrl!,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/asdf.jpg',
                    fit: BoxFit.cover,
                  ),
          ),

          // 2. 이미지 위에 검정색 그라데이션 덮기 (블렌딩 효과)
          Positioned(
            top: halfHeight * 0.5,
            left: 0,
            right: 0,
            height: halfHeight * 0.5,
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

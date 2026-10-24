import 'package:flutter/material.dart';
import 'package:lets_jam/screens/onboarding_screen/steps/step_footer.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

/// 온보딩 1번: 환영 스텝.
class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  const WelcomeStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 원본 비율(1624x1165)로 full width 높이를 계산.
    final imageHeight = screenWidth * 1165 / 1624;
    return Column(
      children: [
        const Spacer(),
        // 본문 가로 패딩(24)을 OverflowBox로 벗어나 화면 full width로 노출.
        SizedBox(
          height: imageHeight,
          child: OverflowBox(
            minWidth: screenWidth,
            maxWidth: screenWidth,
            minHeight: imageHeight,
            maxHeight: imageHeight,
            child: Image.asset(
              'assets/images/onboarding_welcome.png',
              width: screenWidth,
              height: imageHeight,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // 환영 스텝 전용 타이틀 (공용 StepTitle 미사용).
        const Text(
          'JAM에 오신 걸 환영해요!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '함께 합주할 밴드와 멤버를\nJAM에서 찾아보세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: ColorSeed.organizedBlackLight.color,
          ),
        ),
        const Spacer(),
        StepFooter(onConfirm: onNext, confirmText: '다음'),
        const SizedBox(height: 12),
      ],
    );
  }
}

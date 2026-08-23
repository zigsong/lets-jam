import 'package:flutter/material.dart';
import 'package:lets_jam/screens/onboarding_screen/onboarding_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

/// [개발자 전용] isDev 유저만 볼 수 있는 미배포 기능을
/// 확인하는 화면. profiles와 분리된 dev_testers allowlist 유저만 진입한다.
class DeveloperTestScreen extends StatelessWidget {
  const DeveloperTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ColorSeed.boldOrangeMedium.color),
        title: Text(
          'JAM 개발자 테스트',
          style:
              TextStyle(fontSize: 18, color: ColorSeed.boldOrangeMedium.color),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              '아직 배포되지 않은 기능을 미리 확인할 수 있어요.',
              style: TextStyle(
                fontSize: 13,
                color: ColorSeed.organizedBlackLight.color,
              ),
            ),
          ),
          ListTile(
            title: const Text(
              '앱 온보딩',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '처음 설치 온보딩 플로우를 미리 확인해요',
                style: TextStyle(
                  fontSize: 13,
                  color: ColorSeed.meticulousGrayMedium.color,
                ),
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: ColorSeed.organizedBlackLight.color,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OnboardingScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

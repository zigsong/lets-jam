import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/feature_flag_controller.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

/// 개발자 테스트에서 on/off 할 수 있는 기능 플래그 항목.
class _FeatureToggle {
  final String title;
  final String description;
  final RxBool flag;

  const _FeatureToggle({
    required this.title,
    required this.description,
    required this.flag,
  });
}

/// [개발자 전용] isDev 유저만 볼 수 있는 미배포 기능을
/// 켜고 끄는 화면. profiles와 분리된 dev_testers allowlist 유저만 진입한다.
class DeveloperTestScreen extends StatelessWidget {
  const DeveloperTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FeatureFlagController flags = Get.find<FeatureFlagController>();

    // 새 미배포 기능을 만들면 여기에 토글 항목을 추가한다.
    final toggles = <_FeatureToggle>[
      _FeatureToggle(
        title: '합주실',
        description: '하단 탭에 합주실 프로토타입을 노출해요',
        flag: flags.studioEnabled,
      ),
    ];

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
              '아직 배포되지 않은 기능의 노출 여부를 켜고 끌 수 있어요.',
              style: TextStyle(
                fontSize: 13,
                color: ColorSeed.organizedBlackLight.color,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: toggles.length,
              itemBuilder: (context, index) {
                final item = toggles[index];
                return Obx(
                  () => SwitchListTile(
                    activeColor: ColorSeed.boldOrangeStrong.color,
                    title: Text(
                      item.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorSeed.meticulousGrayMedium.color,
                        ),
                      ),
                    ),
                    value: item.flag.value,
                    onChanged: (v) => item.flag.value = v,
                  ),
                );
              },
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFFDDDDDD),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/screens/onboarding_screen/steps/step_footer.dart';
import 'package:lets_jam/screens/onboarding_screen/steps/step_title.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/session_selector.dart';

/// 온보딩 2번: 세션 선택 스텝.
class SessionStep extends StatelessWidget {
  final String? name;
  final String Function(String?) honorific;
  final Set<SessionEnum> selected;
  final ValueChanged<SessionEnum> onToggle;
  final VoidCallback onConfirm;
  final VoidCallback onSkip;

  const SessionStep({
    super.key,
    required this.name,
    required this.honorific,
    required this.selected,
    required this.onToggle,
    required this.onConfirm,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final who = honorific(name);
    final title = who.isEmpty ? '어떤 세션이세요?' : '$who은 어떤 세션이세요?';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        StepTitle(title),
        const SizedBox(height: 12),
        Text(
          '다룰 수 있는 세션을 모두 선택해 주세요',
          style: TextStyle(
            fontSize: 14,
            color: ColorSeed.meticulousGrayMedium.color,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: SessionEnum.values.map((session) {
                return _SessionCard(
                  session: session,
                  selected: selected.contains(session),
                  onTap: () => onToggle(session),
                );
              }).toList(),
            ),
          ),
        ),
        StepFooter(
          onConfirm: onConfirm,
          onSkip: onSkip,
          enabled: selected.isNotEmpty,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// 세션 선택 카드. session_selector.dart의 카드 디자인(80x80 이미지 + 하단 라벨,
/// 선택 시 active 이미지로 토글)을 그대로 따른다.
class _SessionCard extends StatelessWidget {
  final SessionEnum session;
  final bool selected;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Image.asset(
              selected
                  ? sessionImagesActive[session]!
                  : sessionImagesDefault[session]!,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 10),
              child: Text(
                sessionMap[session]!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

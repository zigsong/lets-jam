import 'package:flutter/material.dart';
import 'package:lets_jam/models/genre_enum.dart';
import 'package:lets_jam/screens/onboarding_screen/steps/step_footer.dart';
import 'package:lets_jam/screens/onboarding_screen/steps/step_title.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

/// 온보딩 3번: 음악 취향(장르) 선택 스텝.
class GenreStep extends StatelessWidget {
  final String? name;
  final String Function(String?) honorific;
  final Set<Genre> selected;
  final ValueChanged<Genre> onToggle;
  final VoidCallback onConfirm;
  final VoidCallback onSkip;

  const GenreStep({
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
    final title =
        who.isEmpty ? '멋져요! 🎵\n음악 취향을 알려주세요' : '멋져요! 🎵\n$who의 음악 취향을 알려주세요';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        StepTitle(title),
        const SizedBox(height: 12),
        Text(
          '좋아하는 장르를 모두 골라 주세요',
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
              children: Genre.values.map((genre) {
                return _ChoiceChip(
                  label: genreLabels[genre]!,
                  selected: selected.contains(genre),
                  onTap: () => onToggle(genre),
                );
              }).toList(),
            ),
          ),
        ),
        StepFooter(onConfirm: onConfirm, onSkip: onSkip),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ColorSeed.boldOrangeStrong.color : Colors.white,
          border: Border.all(
            color: selected
                ? ColorSeed.boldOrangeStrong.color
                : ColorSeed.meticulousGrayLight.color,
            // 선택 시 두께가 바뀌면 border가 레이아웃 크기에 포함돼 칩이 커진다.
            // 두께를 고정해 크기 변화를 막는다.
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color:
                selected ? Colors.white : ColorSeed.organizedBlackMedium.color,
          ),
        ),
      ),
    );
  }
}

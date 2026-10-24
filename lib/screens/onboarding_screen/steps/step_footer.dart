import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

/// 스텝 하단 공통: '확인' 기본 버튼 + 선택적 '다음에 작성할게요' 텍스트 버튼.
class StepFooter extends StatelessWidget {
  final bool enabled;
  final VoidCallback onConfirm;
  final VoidCallback? onSkip;
  final String confirmText;

  const StepFooter({
    super.key,
    required this.onConfirm,
    this.onSkip,
    this.enabled = true,
    this.confirmText = '확인',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: enabled ? onConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorSeed.boldOrangeStrong.color,
              disabledBackgroundColor: ColorSeed.meticulousGrayLight.color,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (onSkip != null) ...[
          const SizedBox(height: 22),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '다음에 작성하기',
              style: TextStyle(
                fontSize: 14,
                color: ColorSeed.meticulousGrayMedium.color,
                decoration: TextDecoration.underline,
                decorationColor: ColorSeed.meticulousGrayMedium.color,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

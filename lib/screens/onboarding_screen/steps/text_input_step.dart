import 'package:flutter/material.dart';
import 'package:lets_jam/screens/onboarding_screen/steps/step_footer.dart';
import 'package:lets_jam/screens/onboarding_screen/steps/step_title.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

/// 온보딩의 텍스트 입력 스텝(닉네임·연락처·자기소개 공용).
class TextInputStep extends StatefulWidget {
  final String title;
  final String? description;
  final String hintText;
  final TextEditingController controller;
  final int maxLines;
  final bool allowEmptyConfirm;
  final VoidCallback onConfirm;
  final VoidCallback? onSkip;

  /// 입력 글자 수 제한. null이면 제한 없음. (기본 카운터는 숨긴다)
  final int? maxLength;

  /// 입력 하단에 노출할 에러 메시지. null이면 숨김. 값이 있으면 '확인'도 비활성화된다.
  final String? errorText;

  /// 입력 하단에 노출할 안내 메시지. 에러와 달리 '확인'을 막지 않는다.
  /// (예: 8글자 제한 안내처럼 현재 값은 유효하지만 알려줄 내용이 있을 때)
  final String? noticeText;

  /// 입력값이 바뀔 때마다 호출. (닉네임 중복 검사 등 외부 검증용)
  final ValueChanged<String>? onChanged;

  const TextInputStep({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.onConfirm,
    this.description,
    this.maxLines = 1,
    this.allowEmptyConfirm = false,
    this.onSkip,
    this.maxLength,
    this.errorText,
    this.noticeText,
    this.onChanged,
  });

  @override
  State<TextInputStep> createState() => _TextInputStepState();
}

class _TextInputStepState extends State<TextInputStep> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant TextInputStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 닉네임·연락처·자기소개 스텝은 같은 위젯 타입이라 State가 재사용된다.
    // 컨트롤러가 바뀌면 리스너도 새 컨트롤러로 옮겨줘야 '확인' 활성화가 동작한다.
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
    widget.onChanged?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final hasText =
        widget.allowEmptyConfirm || widget.controller.text.trim().isNotEmpty;
    final enabled = hasText && widget.errorText == null;
    // 에러가 우선, 없으면 안내 문구를 같은 자리에 노출한다.
    final message = widget.errorText ?? widget.noticeText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        StepTitle(widget.title),
        if (widget.description != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.description!,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: ColorSeed.meticulousGrayMedium.color,
            ),
          ),
        ],
        const SizedBox(height: 32),
        TextField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: ColorSeed.meticulousGrayMedium.color),
            // 가로/세로 여백을 동일하게.
            contentPadding: const EdgeInsets.all(16),
            // 기본 글자 수 카운터는 숨긴다.
            counterText: '',
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: ColorSeed.boldOrangeStrong.color, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: ColorSeed.meticulousGrayLight.color),
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.info,
                size: 16,
                color: ColorSeed.boldOrangeStrong.color,
              ),
              const SizedBox(width: 6),
              Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  color: ColorSeed.boldOrangeStrong.color,
                ),
              ),
            ],
          ),
        ],
        const Spacer(),
        StepFooter(
          onConfirm: widget.onConfirm,
          onSkip: widget.onSkip,
          enabled: enabled,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

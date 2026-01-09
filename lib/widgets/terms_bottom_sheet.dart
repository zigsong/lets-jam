import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/wide_button.dart';

class TermsBottomSheet extends StatefulWidget {
  final VoidCallback onAgree;
  final VoidCallback onClose;

  const TermsBottomSheet({
    super.key,
    required this.onAgree,
    required this.onClose,
  });

  @override
  State<TermsBottomSheet> createState() => _TermsBottomSheetState();
}

class _TermsBottomSheetState extends State<TermsBottomSheet> {
  bool _allAgreed = false;
  bool _termsOfService = false;
  bool _privacyPolicy = false;
  bool _ageVerification = false;

  void _toggleAll(bool? value) {
    setState(() {
      _allAgreed = value ?? false;
      _termsOfService = _allAgreed;
      _privacyPolicy = _allAgreed;
      _ageVerification = _allAgreed;
    });
  }

  void _updateAllAgreed() {
    setState(() {
      _allAgreed = _termsOfService && _privacyPolicy && _ageVerification;
    });
  }

  bool get _canProceed => _termsOfService && _privacyPolicy && _ageVerification;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '서비스 이용약관 동의',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _CheckboxItem(
                title: '전체 동의',
                value: _allAgreed,
                onChanged: _toggleAll,
                isMain: true,
              ),
              const Divider(height: 24),
              _CheckboxItem(
                title: '(필수) 서비스 이용약관',
                value: _termsOfService,
                onChanged: (value) {
                  setState(() {
                    _termsOfService = value ?? false;
                    _updateAllAgreed();
                  });
                },
                onDetailTap: () {
                  // TODO: 서비스 이용약관 상세 페이지
                },
              ),
              const SizedBox(height: 16),
              _CheckboxItem(
                title: '(필수) 개인정보 처리방침',
                value: _privacyPolicy,
                onChanged: (value) {
                  setState(() {
                    _privacyPolicy = value ?? false;
                    _updateAllAgreed();
                  });
                },
                onDetailTap: () {
                  // TODO: 개인정보 처리방침 상세 페이지
                },
              ),
              const SizedBox(height: 16),
              _CheckboxItem(
                title: '(필수) 만 14세 이상입니다',
                value: _ageVerification,
                onChanged: (value) {
                  setState(() {
                    _ageVerification = value ?? false;
                    _updateAllAgreed();
                  });
                },
              ),
              const SizedBox(height: 24),
              WideButton(
                text: '동의하고 시작하기',
                onPressed: _canProceed ? widget.onAgree : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckboxItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onDetailTap;
  final bool isMain;

  const _CheckboxItem({
    required this.title,
    required this.value,
    this.onChanged,
    this.onDetailTap,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: ColorSeed.boldOrangeMedium.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isMain ? 16 : 14,
              fontWeight: isMain ? FontWeight.w600 : FontWeight.normal,
              color:
                  isMain ? Colors.black : ColorSeed.organizedBlackMedium.color,
            ),
          ),
        ),
        if (onDetailTap != null)
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: ColorSeed.meticulousGrayMedium.color,
              size: 20,
            ),
            onPressed: onDetailTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}

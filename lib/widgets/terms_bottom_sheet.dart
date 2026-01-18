import 'package:flutter/material.dart';
import 'package:lets_jam/screens/terms_detail_screen.dart';
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

  void _toggleAll(bool? value) {
    setState(() {
      _allAgreed = value ?? false;
      _termsOfService = _allAgreed;
      _privacyPolicy = _allAgreed;
    });
  }

  void _updateAllAgreed() {
    setState(() {
      _allAgreed = _termsOfService && _privacyPolicy;
    });
  }

  bool get _canProceed => _termsOfService && _privacyPolicy;

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
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const Center(
                child: Text(
                  'JAM 서비스 이용약관 동의',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                title: '이용약관(필수)',
                value: _termsOfService,
                onChanged: (value) {
                  setState(() {
                    _termsOfService = value ?? false;
                    _updateAllAgreed();
                  });
                },
                onDetailTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsDetailScreen(
                        type: TermsType.termsOfService,
                      ),
                    ),
                  );
                },
              ),
              _CheckboxItem(
                title: '개인정보 수집 및 이용동의(필수)',
                value: _privacyPolicy,
                onChanged: (value) {
                  setState(() {
                    _privacyPolicy = value ?? false;
                    _updateAllAgreed();
                  });
                },
                onDetailTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsDetailScreen(
                        type: TermsType.privacyPolicy,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              WideButton(
                text: 'JAM 시작하기',
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
        GestureDetector(
          onTap: () => onChanged?.call(!value),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: value
                    ? ColorSeed.boldOrangeMedium.color
                    : ColorSeed.meticulousGrayMedium.color,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            child: value
                ? Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: ColorSeed.boldOrangeMedium.color,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isMain ? 16 : 14,
              fontWeight: FontWeight.normal,
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

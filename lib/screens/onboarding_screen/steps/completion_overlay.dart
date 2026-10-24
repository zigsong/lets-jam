import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

/// 홈 위에 딤드로 뜨는 '작성 완료' 오버레이. 페이드 인 후
/// [onDismiss]로 OverlayEntry를 제거한다.
class CompletionOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const CompletionOverlay({super.key, required this.onDismiss});

  @override
  State<CompletionOverlay> createState() => _CompletionOverlayState();
}

class _CompletionOverlayState extends State<CompletionOverlay> {
  static const Duration _fade = Duration(milliseconds: 250);
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    // 페이드 인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: _fade,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            color: Colors.black.withOpacity(0.55),
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/onboarding_complete.png',
                    width: 140,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '프로필 완성!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ColorSeed.boldOrangeStrong.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '이제 JAM에서 밴드와 멤버를 만나보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: ColorSeed.organizedBlackMedium.color,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: widget.onDismiss,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorSeed.boldOrangeStrong.color,
                        side: BorderSide(
                          color: ColorSeed.boldOrangeStrong.color,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'JAM 시작하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

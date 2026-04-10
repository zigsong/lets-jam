import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/screens/email_auth_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionController sessionController = Get.find<SessionController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ColorSeed.boldOrangeStrong.color),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Image.asset('assets/images/jam_full_logo.png', width: 160),
              const SizedBox(height: 12),
              Text(
                '째미난 밴드 라이프 커뮤니티',
                style: TextStyle(
                  fontSize: 14,
                  color: ColorSeed.boldOrangeMedium.color,
                ),
              ),
              const Spacer(),
              // 카카오로 시작하기
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => sessionController.signIn(),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: const Color(0xFF191919),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/kakao.svg',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '카카오로 시작하기',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 이메일로 시작하기
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EmailAuthScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: ColorSeed.organizedBlackMedium.color,
                    side: BorderSide(
                      color: ColorSeed.meticulousGrayLight.color,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '이메일로 시작하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Apple로 시작하기
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => sessionController.signInWithApple(),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF000000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apple, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Apple로 시작하기',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/screens/onboarding_screen/onboarding_screen.dart';
import 'package:lets_jam/widgets/terms_bottom_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TermsAgreementScreen extends StatefulWidget {
  final User user;

  const TermsAgreementScreen({super.key, required this.user});

  @override
  State<TermsAgreementScreen> createState() => _TermsAgreementScreenState();
}

class _TermsAgreementScreenState extends State<TermsAgreementScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 빌드된 후 바텀시트 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTermsBottomSheet();
    });
  }

  void _showTermsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => TermsBottomSheet(
        onAgree: () async {
          Navigator.pop(context);
          await Supabase.instance.client.from('user_consents').upsert({
            'user_id': widget.user.id,
          });
          // 약관 동의 후 온보딩(프로필 작성)으로 이동
          Get.off(() => const OnboardingScreen());
        },
        onClose: () {
          Navigator.pop(context);
          // 약관 동의하지 않으면 로그아웃
          Supabase.instance.client.auth.signOut();
          Get.back();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}

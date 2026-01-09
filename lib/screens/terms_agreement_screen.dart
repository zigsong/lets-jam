import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/screens/welcome_screen.dart';
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
        onAgree: () {
          Navigator.pop(context);
          // 약관 동의 후 회원가입 완료 화면으로 이동
          Get.off(() => WelcomeScreen(user: widget.user));
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

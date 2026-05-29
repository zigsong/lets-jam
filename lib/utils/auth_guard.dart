import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/screens/auth_screen.dart';
import 'package:lets_jam/screens/profile_screen/profile_upload_screen.dart';
import 'package:lets_jam/widgets/modal.dart';

void requireAuthAndProfile(
  BuildContext context, {
  required VoidCallback onAuthorized,
}) {
  final s = Get.find<SessionController>();
  if (!s.isLoggedIn.value) {
    showModal(
      context: context,
      desc: '로그인 후에 이용할 수 있어요',
      confirmText: '로그인',
      onConfirm: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      ),
      cancelText: '다음에 할게요',
      onCancel: null,
    );
    return;
  }
  if (!s.hasProfile.value) {
    showModal(
      context: context,
      desc: '프로필이 없어요.\n프로필을 작성할까요?',
      confirmText: '작성하기',
      onConfirm: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileUploadScreen()),
      ),
      cancelText: '다음에 할게요',
    );
    return;
  }
  onAuthorized();
}

import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

void showPhotoPermissionDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (ctx) => CupertinoTheme(
      data: const CupertinoThemeData(
        primaryColor: Color(0xFF007AFF),
      ),
      child: CupertinoAlertDialog(
        title: const Text('사진 접근이 차단되어있어요'),
        content: const Text('설정 > JAM > 사진에서\n사진 접근을 허용해주세요.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(ctx);
              launchUrl(Uri.parse('app-settings:'));
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    ),
  );
}

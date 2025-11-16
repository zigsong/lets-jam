import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class Modal extends StatelessWidget {
  const Modal(
      {super.key,
      this.title,
      required this.desc,
      this.cancelText,
      this.confirmText,
      required this.onConfirm,
      this.onCancel});

  final String? title;
  final dynamic desc;
  final String? cancelText;
  final String? confirmText;

  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Column(children: [
                Text(
                  title!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
              ]),
            if (desc is String) Text(desc) else desc,
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(
                    cancelText ?? '취소',
                    style: TextStyle(color: ColorSeed.boldOrangeRegular.color),
                  ),
                  onPressed: () {
                    onCancel?.call();
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: ColorSeed.boldOrangeStrong.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w500, inherit: false)),
                  child: Text(confirmText ?? '확인'),
                  onPressed: () {
                    onConfirm();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showModal({
  required BuildContext context,
  String? title,
  required dynamic desc,
  String? cancelText,
  String? confirmText,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "다이얼로그 닫기",
    barrierColor: ColorSeed.organizedBlackMedium.color.withOpacity(0.7),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (modalContext, __, ___) {
      return Center(
        child: Modal(
          title: title,
          desc: desc,
          cancelText: cancelText,
          confirmText: confirmText,
          onConfirm: () {
            Navigator.of(modalContext).pop();
            onConfirm(); // 외부에서 액션 처리
          },
          onCancel: () {
            Navigator.of(modalContext).pop();
            onCancel?.call();
          },
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
        ),
        child: FadeTransition(
          opacity: anim,
          child: child,
        ),
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class Modal extends StatefulWidget {
  const Modal(
      {super.key,
      this.title,
      required this.desc,
      this.cancelText,
      this.confirmText,
      this.onConfirm,
      this.asyncOnConfirm,
      this.onCancel});

  final String? title;
  final dynamic desc;
  final String? cancelText;
  final String? confirmText;

  final VoidCallback? onConfirm;
  final Future<void> Function()? asyncOnConfirm;
  final VoidCallback? onCancel;

  @override
  State<Modal> createState() => _ModalState();
}

class _ModalState extends State<Modal> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (widget.asyncOnConfirm != null) {
      setState(() => _isLoading = true);
      try {
        await widget.asyncOnConfirm!();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      widget.onConfirm?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding:
            const EdgeInsets.only(top: 30, left: 24, right: 24, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != null)
              Column(children: [
                Center(
                  child: Text(
                    widget.title!,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            if (widget.desc is String)
              Text(
                widget.desc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              )
            else
              Center(child: widget.desc),
            const SizedBox(height: 24),
            Padding(
              padding: (widget.confirmText == null) != (widget.cancelText == null)
                  ? const EdgeInsets.symmetric(horizontal: 56)
                  : EdgeInsets.zero,
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorSeed.boldOrangeRegular.color,
                        side: BorderSide(
                            color: ColorSeed.boldOrangeRegular.color,
                            width: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            inherit: false),
                      ),
                      onPressed: _isLoading ? null : () {
                        widget.onCancel?.call();
                      },
                      child: Text(widget.cancelText ?? '취소'),
                    ),
                  ),
                  if (widget.confirmText != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: ColorSeed.boldOrangeStrong.color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                inherit: false)),
                        onPressed: _isLoading ? null : _handleConfirm,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(widget.confirmText!),
                      ),
                    ),
                  ],
                ],
              ),
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
  VoidCallback? onConfirm,
  Future<void> Function()? asyncOnConfirm,
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
          onConfirm: onConfirm != null
              ? () {
                  Navigator.of(modalContext).pop();
                  onConfirm();
                }
              : null,
          asyncOnConfirm: asyncOnConfirm != null
              ? () async {
                  await asyncOnConfirm();
                  if (modalContext.mounted) Navigator.of(modalContext).pop();
                }
              : null,
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

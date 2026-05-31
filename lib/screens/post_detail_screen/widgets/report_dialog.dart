import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

void showReportDialog(
  BuildContext context, {
  required Future<void> Function() onReport,
}) {
  final reasons = ['스팸', '욕설/혐오', '음란물', '사기/허위정보', '기타'];
  String? selectedReason;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorSeed.meticulousGrayLight.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('게시글 신고',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                '신고 사유를 선택해주세요',
                style: TextStyle(
                    fontSize: 13,
                    color: ColorSeed.meticulousGrayMedium.color),
              ),
              const SizedBox(height: 16),
              ...reasons.map((reason) => GestureDetector(
                    onTap: () =>
                        setSheetState(() => selectedReason = reason),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: selectedReason == reason
                            ? ColorSeed.boldOrangeLight.color
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selectedReason == reason
                              ? ColorSeed.boldOrangeRegular.color
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        reason,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: selectedReason == reason
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: selectedReason == reason
                              ? ColorSeed.boldOrangeStrong.color
                              : ColorSeed.organizedBlackMedium.color,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorSeed.boldOrangeRegular.color,
                        side: BorderSide(
                            color: ColorSeed.boldOrangeRegular.color,
                            width: 0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('취소',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedReason == null
                          ? null
                          : () {
                              Navigator.pop(sheetContext);
                              onReport();
                            },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: ColorSeed.boldOrangeStrong.color,
                        disabledBackgroundColor:
                            ColorSeed.meticulousGrayLight.color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('신고하기',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

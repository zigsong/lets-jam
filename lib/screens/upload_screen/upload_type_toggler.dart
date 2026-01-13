import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class UploadTypeToggler extends StatelessWidget {
  final void Function(PostTypeEnum) onSelect;
  final PostTypeEnum? selectedType;
  final bool showError;

  const UploadTypeToggler({
    super.key,
    required this.onSelect,
    required this.selectedType,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '어떤 글인가요?',
              style: TextStyle(
                  fontSize: 13, color: ColorSeed.organizedBlackMedium.color),
            ),
            const SizedBox(
              width: 2,
            ),
            Text('*', style: TextStyle(color: ColorSeed.boldOrangeStrong.color))
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(PostTypeEnum.findBand),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selectedType == PostTypeEnum.findBand
                            ? ColorSeed.boldOrangeStrong.color
                            : ColorSeed.meticulousGrayMedium.color,
                      ),
                      color: selectedType == PostTypeEnum.findBand
                          ? ColorSeed.boldOrangeLight.color
                          : Colors.transparent),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '밴드 들어가기',
                              style: TextStyle(
                                color: selectedType == PostTypeEnum.findBand
                                    ? ColorSeed.boldOrangeStrong.color
                                    : ColorSeed.meticulousGrayMedium.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              '내가 들어갈 밴드를 찾아요',
                              style: TextStyle(
                                  color: selectedType == PostTypeEnum.findBand
                                      ? ColorSeed.boldOrangeStrong.color
                                      : ColorSeed.meticulousGrayMedium.color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: selectedType == PostTypeEnum.findBand
                                ? ColorSeed.boldOrangeStrong.color
                                : ColorSeed.meticulousGrayMedium.color),
                        width: 24,
                        height: 24,
                        child: Center(
                          child: Image.asset(
                            'assets/icons/check.png',
                            width: 11.5,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(PostTypeEnum.findMember),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selectedType == PostTypeEnum.findMember
                            ? ColorSeed.boldOrangeStrong.color
                            : ColorSeed.meticulousGrayMedium.color,
                      ),
                      color: selectedType == PostTypeEnum.findMember
                          ? ColorSeed.boldOrangeLight.color
                          : Colors.transparent),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '멤버 구하기',
                              style: TextStyle(
                                color: selectedType == PostTypeEnum.findMember
                                    ? ColorSeed.boldOrangeStrong.color
                                    : ColorSeed.meticulousGrayMedium.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              '함께할 멤버를 구해요',
                              style: TextStyle(
                                  color: selectedType == PostTypeEnum.findMember
                                      ? ColorSeed.boldOrangeStrong.color
                                      : ColorSeed.meticulousGrayMedium.color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: selectedType == PostTypeEnum.findMember
                                ? ColorSeed.boldOrangeStrong.color
                                : ColorSeed.meticulousGrayMedium.color),
                        width: 24,
                        height: 24,
                        child: Center(
                          child: Image.asset(
                            'assets/icons/check.png',
                            width: 11.5,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 13.5,
                      height: 13.5,
                      child: Image.asset('assets/icons/info.png')),
                  const SizedBox(width: 7),
                  const Text(
                    '글의 유형을 선택해주세요',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

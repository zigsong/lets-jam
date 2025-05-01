import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class ReplyContent extends StatefulWidget {
  const ReplyContent({super.key});

  @override
  State<ReplyContent> createState() => _ReplyContentState();
}

class _ReplyContentState extends State<ReplyContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      // 여기 Row는 width 100임
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
            clipBehavior: Clip.antiAlias,
            // @zigsong TODO: 세션 유저 프로필로 바꾸기
            child: Image.asset('assets/images/profile_avatar.png'),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '닉네임',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        Text(
                          '2분 전',
                          style: TextStyle(
                              fontSize: 12,
                              color: ColorSeed.meticulousGrayMedium.color),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ReplyButton(text: '수정', onPressed: () {}),
                        const SizedBox(
                          width: 8,
                        ),
                        ReplyButton(text: '삭제', onPressed: () {}),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                // const Text('댓글 내용'),
                const Text(
                  '모든 국민은 통신의 비밀을 침해받지 아니한다. 모든 국민은 법률이 정하는 바에 의하여 납세의 의무를 진다. 공무원은 국민전체에 대한 봉사자이며, 국민에 대하여 책임을 진다. 대통령으로 선거될 수 있는 자는 국회의원의 피선거권이 있고 선거일 현재 40세에 달하여야 한다. 국무회의는 대통령·국무총리와 15인 이상 30인 이하의 국무위원으로 구성한다.',
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ReplyButton extends StatelessWidget {
  final String text;
  final Function() onPressed;

  const ReplyButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13.5, vertical: 8.5),
        decoration: BoxDecoration(
          border: Border.all(color: ColorSeed.meticulousGrayMedium.color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style:
              TextStyle(color: ColorSeed.meticulousGrayMedium.color, height: 1),
        ),
      ),
    );
  }
}

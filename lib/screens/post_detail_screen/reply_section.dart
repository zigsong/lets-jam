import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/text_input.dart';

class ReplySection extends StatefulWidget {
  const ReplySection({super.key});

  @override
  State<ReplySection> createState() => _ReplySectionState();
}

class _ReplySectionState extends State<ReplySection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '댓글 N',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 10,
            ),
            ReplyInput()
          ],
        ),
      ),
    );
  }
}

class ReplyInput extends StatefulWidget {
  const ReplyInput({super.key});

  @override
  State<ReplyInput> createState() => _ReplyInputState();
}

class _ReplyInputState extends State<ReplyInput> {
  String _value = '';

  @override
  Widget build(BuildContext context) {
    return Row(
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
        /** @zigsong TODO: 댓글 placeholder 필요 */
        Expanded(
          child: TextInput(
            onChange: (value) {
              setState(() {
                _value = value!;
              });
            },
            keyboardType: TextInputType.multiline,
            height: 40,
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: ColorSeed.organizedBlackMedium.color,
                padding: const EdgeInsets.all(13.5),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6))),
            onPressed: () {},
            child: const Text(
              '등록',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500, height: 1),
            ))
      ],
    );
  }
}

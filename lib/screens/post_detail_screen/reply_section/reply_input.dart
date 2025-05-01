import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/text_input.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReplyInput extends StatefulWidget {
  const ReplyInput({super.key, required this.postId});

  final String postId;

  @override
  State<ReplyInput> createState() => _ReplyInputState();
}

class _ReplyInputState extends State<ReplyInput> {
  final supabase = Supabase.instance.client;
  final SessionController sessionController = Get.find<SessionController>();

  String _value = '';

  Future<void> _saveReplyToSupabase() async {
    final currentUser = sessionController.user.value;
    if (currentUser == null) return;

    try {
      await supabase.from('comments').insert({
        'post_id': widget.postId,
        'user_id': currentUser.id,
        'content': _value
      });
    } catch (err) {
      print('댓글 등록 에러: $err');
    }
  }

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
            onPressed: _saveReplyToSupabase,
            child: const Text(
              '등록',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500, height: 1),
            ))
      ],
    );
  }
}

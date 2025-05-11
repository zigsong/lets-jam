import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/text_input.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReplyInput extends StatefulWidget {
  const ReplyInput({super.key, required this.postId, required this.onSubmit});

  final String postId;
  final void Function() onSubmit;

  @override
  State<ReplyInput> createState() => _ReplyInputState();
}

class _ReplyInputState extends State<ReplyInput> {
  final supabase = Supabase.instance.client;
  final SessionController sessionController = Get.find<SessionController>();
  final TextEditingController _textEditingController = TextEditingController();

  String _value = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submit() async {
    if (_value == '') return;

    final currentUser = sessionController.user.value;
    if (currentUser == null) return;

    try {
      await supabase.from('comments').insert({
        'post_id': widget.postId,
        'user_id': currentUser.id,
        'content': _value
      });

      final content = _textEditingController.text;
      if (content.isNotEmpty) {
        _textEditingController.clear();

        setState(() {
          _value = '';
        });
      }

      widget.onSubmit();
    } catch (err) {
      print('댓글 등록 에러: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = sessionController.user.value;

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          clipBehavior: Clip.antiAlias,
          child: currentUser?.profileImage != null
              ? Image.network(
                  currentUser!.profileImage!.path,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                )
              : Image.asset('assets/images/profile_avatar.png'),
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: TextInput(
            controller: _textEditingController,
            placeholder: '댓글을 작성해 주세요',
            onChange: (value) {
              setState(() {
                _value = value!;
              });
            },
            keyboardType: TextInputType.multiline,
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
            onPressed: _submit,
            child: const Text(
              '등록',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500, height: 1),
            ))
      ],
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/screens/profile_screen/profile_upload_screen.dart';
import 'package:lets_jam/utils/image_utils.dart';
import 'package:lets_jam/widgets/modal.dart';
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
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          clipBehavior: Clip.antiAlias,
          child: currentUser?.profileImage?.isNotEmpty == true
              ? CachedNetworkImage(
                    fadeInDuration: Duration.zero,
                  imageUrl: supabaseImageUrl(currentUser!.profileImage!,
                      width: 80, quality: 80),
                  fit: BoxFit.cover,
                  memCacheWidth: 80,
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
            onTap: () {
              if (sessionController.isLoggedIn.value == false) {
                FocusManager.instance.primaryFocus?.unfocus();
                showModal(
                    context: context,
                    desc: '로그인 후에 이용할 수 있어요',
                    confirmText: '로그인',
                    onConfirm: () {
                      sessionController.signIn();
                    },
                    cancelText: '다음에 할게요',
                    onCancel: null);
              } else if (sessionController.hasProfile.value == false) {
                FocusManager.instance.primaryFocus?.unfocus();
                showModal(
                  context: context,
                  desc: '프로필이 없어요.\n프로필을 작성할까요?',
                  confirmText: '작성하기',
                  onConfirm: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ProfileUploadScreen(),
                    ));
                  },
                  cancelText: '다음에 할게요',
                );
              }
            },
            onChanged: (value) {
              setState(() {
                _value = value;
              });
            },
            suffixButton: Image.asset(
              'assets/icons/send.png',
              width: 20,
            ),
            onSubmit: _submit,
            keyboardType: TextInputType.multiline,
          ),
        ),
      ],
    );
  }
}

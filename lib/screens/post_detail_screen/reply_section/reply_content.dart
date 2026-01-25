import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/reply_model.dart';
import 'package:lets_jam/models/user_model.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/utils/date_parser.dart';
import 'package:lets_jam/widgets/modal.dart';
import 'package:lets_jam/widgets/text_input.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReplyContent extends StatefulWidget {
  const ReplyContent({super.key, required this.reply, required this.onRefresh});

  final ReplyModel reply;
  final void Function() onRefresh;

  @override
  State<ReplyContent> createState() => _ReplyContentState();
}

class _ReplyContentState extends State<ReplyContent> {
  final supabase = Supabase.instance.client;

  final SessionController sessionController = Get.find<SessionController>();
  late Future<UserModel> _author;
  late String _editingValue;

  bool? isMyReply;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _author = _fetchUserById();
    _editingValue = widget.reply.content;
  }

  Future<UserModel> _fetchUserById() async {
    try {
      final response = await supabase
          .from('users')
          .select('*')
          .eq('id', widget.reply.userId)
          .single();

      final author = UserModel.fromJson(response);

      setState(() {
        isMyReply = author == sessionController.user.value;
      });

      return author;
    } catch (error) {
      print('댓글 작성자 불러오기 에러 : $error');
      throw Error;
    }
  }

  Future<void> _editReply() async {
    try {
      await supabase.from('comments').update({
        'content': _editingValue,
      }).eq('id', widget.reply.id);

      widget.onRefresh();
    } catch (error) {
      print('댓글 수정 에러 : $error');

      ScaffoldMessenger.of(context)
          .showSnackBar(customSnackbar('댓글 수정에 실패했어요'));

      throw Error;
    }
  }

  Future<void> _deleteReply() async {
    try {
      await supabase.from('comments').delete().eq('id', widget.reply.id);
      widget.onRefresh();
    } catch (error) {
      print('댓글 삭제 에러 : $error');

      ScaffoldMessenger.of(context)
          .showSnackBar(customSnackbar('댓글 삭제에 실패했어요'));

      throw Error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _author,
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final author = snapshot.data!;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(100)),
                clipBehavior: Clip.antiAlias,
                child: author.profileImage != null
                    ? Image.network(
                        author.profileImage!.path,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      )
                    : Image.asset('assets/images/profile_avatar.png'),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author.nickname,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                            Text(
                              getRelativeTime(widget.reply.createdAt),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: ColorSeed.meticulousGrayMedium.color),
                            ),
                          ],
                        ),
                        if (isMyReply == true)
                          !isEditing
                              ? Row(
                                  children: [
                                    IconButton(
                                        text: '수정',
                                        leftIcon: Image.asset(
                                          'assets/icons/reply_edit.png',
                                          width: 15,
                                          height: 15,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isEditing = true;
                                          });
                                        }),
                                    const SizedBox(width: 12),
                                    IconButton(
                                        text: '삭제',
                                        leftIcon: Image.asset(
                                          'assets/icons/reply_delete.png',
                                          width: 15,
                                          height: 15,
                                        ),
                                        onPressed: () {
                                          showModal(
                                            context: context,
                                            desc: '댓글을 정말 삭제할까요?',
                                            confirmText: '삭제',
                                            onConfirm: _deleteReply,
                                          );
                                        }),
                                  ],
                                )
                              : Row(
                                  children: [
                                    BorderButton(
                                        text: '취소',
                                        onPressed: () {
                                          setState(() {
                                            isEditing = false;
                                          });
                                        }),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    BorderButton(
                                        text: '저장',
                                        isReversed: true,
                                        onPressed: () {
                                          _editReply();
                                          setState(() {
                                            isEditing = false;
                                          });
                                        }),
                                  ],
                                )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    isEditing == false
                        ? Text(
                            widget.reply.content,
                            textAlign: TextAlign.left,
                          )
                        : TextInput(
                            initialValue: widget.reply.content,
                            onChanged: (value) {
                              setState(() {
                                _editingValue = value;
                              });
                            },
                            keyboardType: TextInputType.multiline,
                          ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class IconButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final bool? isReversed;
  final Widget? leftIcon;

  const IconButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.isReversed = false,
      this.leftIcon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.5),
        decoration: BoxDecoration(
          color: isReversed == false
              ? Colors.white
              : ColorSeed.organizedBlackMedium.color,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leftIcon != null) ...[
              leftIcon!,
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(
                  color: isReversed == false
                      ? ColorSeed.meticulousGrayMedium.color
                      : Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class BorderButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final bool isReversed;

  const BorderButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.isReversed = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 7),
        decoration: BoxDecoration(
            color: isReversed
                ? ColorSeed.meticulousGrayMedium.color
                : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: ColorSeed.meticulousGrayMedium.color)),
        child: Text(
          text,
          style: TextStyle(
              color: isReversed
                  ? Colors.white
                  : ColorSeed.meticulousGrayMedium.color,
              height: 1,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

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
          padding: const EdgeInsets.only(bottom: 20),
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
                                    AccessoryButton(
                                        text: '수정',
                                        onPressed: () {
                                          setState(() {
                                            isEditing = true;
                                          });
                                        }),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    AccessoryButton(
                                        text: '삭제',
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
                                    AccessoryButton(
                                        text: '취소',
                                        onPressed: () {
                                          setState(() {
                                            isEditing = false;
                                          });
                                        }),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    AccessoryButton(
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

class AccessoryButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final bool? isReversed;

  const AccessoryButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.isReversed = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13.5, vertical: 8.5),
        decoration: BoxDecoration(
          color: isReversed == false
              ? Colors.white
              : ColorSeed.organizedBlackMedium.color,
          border: Border.all(
              color: isReversed == false
                  ? ColorSeed.meticulousGrayMedium.color
                  : ColorSeed.organizedBlackMedium.color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: isReversed == false
                  ? ColorSeed.meticulousGrayMedium.color
                  : Colors.white,
              height: 1,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

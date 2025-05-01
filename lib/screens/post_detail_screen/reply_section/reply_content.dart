import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/reply_model.dart';
import 'package:lets_jam/models/user_model.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/date_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReplyContent extends StatefulWidget {
  const ReplyContent({super.key, required this.reply});

  final ReplyModel reply;

  @override
  State<ReplyContent> createState() => _ReplyContentState();
}

class _ReplyContentState extends State<ReplyContent> {
  final supabase = Supabase.instance.client;

  final SessionController sessionController = Get.find<SessionController>();
  late Future<UserModel> _author;

  bool? isMyReply;

  @override
  void initState() {
    super.initState();
    _author = _fetchUserById();
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
                width: 50,
                height: 50,
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
                    Text(
                      widget.reply.content,
                      textAlign: TextAlign.left,
                    )
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

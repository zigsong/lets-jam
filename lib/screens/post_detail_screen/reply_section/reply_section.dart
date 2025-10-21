import 'package:flutter/material.dart';
import 'package:lets_jam/models/reply_model.dart';
import 'package:lets_jam/screens/post_detail_screen/reply_section/reply_content.dart';
import 'package:lets_jam/screens/post_detail_screen/reply_section/reply_input.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReplySection extends StatefulWidget {
  const ReplySection({super.key, required this.postId});

  final String postId;

  @override
  State<ReplySection> createState() => _ReplySectionState();
}

class _ReplySectionState extends State<ReplySection> {
  final supabase = Supabase.instance.client;

  late Future<List<ReplyModel>> _replys;

  Future<List<ReplyModel>> _fetchReplys() async {
    final response = await supabase
        .from('comments')
        .select()
        .eq('post_id', widget.postId)
        .order('created_at', ascending: false);

    return response
        .map<ReplyModel>((json) => ReplyModel.fromJson(json))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _replys = _fetchReplys();
  }

  void _refresh() {
    setState(() {
      _replys = _fetchReplys();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _replys,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final replys = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '댓글 ${replys.length}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 10,
                ),
                ReplyInput(
                  postId: widget.postId,
                  onSubmit: _refresh,
                ),
                const SizedBox(
                  height: 20,
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: replys.length,
                  itemBuilder: (context, index) {
                    final reply = replys[index];
                    return ReplyContent(
                      key: ValueKey(reply.id),
                      reply: reply,
                      onRefresh: _refresh,
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    color: ColorSeed.meticulousGrayLight.color,
                    thickness: 0.5,
                    height: 10,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

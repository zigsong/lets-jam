import 'package:flutter/material.dart';
import 'package:lets_jam/screens/post_detail_screen/reply_section/reply_content.dart';
import 'package:lets_jam/screens/post_detail_screen/reply_section/reply_input.dart';

class ReplySection extends StatefulWidget {
  const ReplySection({super.key, required this.postId});

  final String postId;

  @override
  State<ReplySection> createState() => _ReplySectionState();
}

class _ReplySectionState extends State<ReplySection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '댓글 N',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 10,
            ),
            ReplyInput(
              postId: widget.postId,
            ),
            const SizedBox(
              height: 20,
            ),
            const Column(
              children: [ReplyContent(), ReplyContent(), ReplyContent()],
            )
          ],
        ),
      ),
    );
  }
}

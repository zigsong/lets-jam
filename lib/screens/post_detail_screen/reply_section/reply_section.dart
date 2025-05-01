import 'package:flutter/material.dart';
import 'package:lets_jam/screens/post_detail_screen/reply_section/reply_content.dart';
import 'package:lets_jam/screens/post_detail_screen/reply_section/reply_input.dart';

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
            ReplyInput(),
            SizedBox(
              height: 20,
            ),
            Column(
              children: [ReplyContent(), ReplyContent(), ReplyContent()],
            )
          ],
        ),
      ),
    );
  }
}

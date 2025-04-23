import 'package:flutter/material.dart';

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
          children: [
            Text(
              '댓글 N',
              style: TextStyle(fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}

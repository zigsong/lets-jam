import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post});

  final PostModel post;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 248,
            decoration: const BoxDecoration(color: Colors.grey),
            child: const Center(child: Text('이미지')),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 20,
                ),
                const PostDetailAuthorInfo()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostDetailAuthorInfo extends StatelessWidget {
  const PostDetailAuthorInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(width: 1, color: Color(0xffCACACA)),
              bottom: BorderSide(width: 1, color: Color(0xffCACACA)))),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(100)),
                ),
                const SizedBox(
                  width: 12,
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '김소연',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '기타/ASDF',
                      style: TextStyle(fontSize: 14, color: Color(0xff838589)),
                    )
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.more_vert,
            color: Color(0xff606060),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';

class PostThumbnail extends StatelessWidget {
  final PostModel post;

  const PostThumbnail({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: const Color(0xffEFEFF0)),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffD9D9D9),
              borderRadius: BorderRadius.circular(8),
            ),
            width: 96,
            height: 96,
            child: const Center(child: Text('이미지')),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(post.createdAt.toString()),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

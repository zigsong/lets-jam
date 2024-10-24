import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/widgets/tag.dart';

class PostThumbnail extends StatelessWidget {
  final PostModel post;

  const PostThumbnail({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
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
            width: 106,
            height: 106,
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
                  const SizedBox(
                    height: 4,
                  ),
                  SizedBox(
                    height: 28,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: post.sessions.length,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return Tag(
                            size: TagSizeEnum.small,
                            text: post.sessions[index].name);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 4,
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

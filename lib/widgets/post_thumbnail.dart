import 'package:flutter/material.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/utils/date_parser.dart';
import 'package:lets_jam/utils/helper.dart';
import 'package:lets_jam/widgets/tag.dart';

class PostThumbnail extends StatelessWidget {
  final PostModel post;

  const PostThumbnail({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    print('여긴데: ${post.ages}');

    return Container(
      height: 106,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: const Color(0xffEFEFF0)),
          borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
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
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  SizedBox(
                      height: 28,
                      child: Row(
                        children: [
                          Tag(
                              size: TagSizeEnum.small,
                              text: formatList(post.sessions
                                  .map((session) => sessionMap[session])
                                  .toList())),
                          const SizedBox(
                            width: 2,
                          ),
                          if (post.regions != null)
                            Tag(
                                size: TagSizeEnum.small,
                                text: formatList(post.regions!)),
                          const SizedBox(
                            width: 2,
                          ),
                          Tag(
                              size: TagSizeEnum.small,
                              text: formatList(post.levels
                                  .map((level) => levelMap[level])
                                  .toList())),
                          const SizedBox(
                            width: 2,
                          ),
                          if (post.ages != null)
                            Tag(
                                size: TagSizeEnum.small,
                                text: formatList(post.ages!
                                    .map((age) => ageMap[age])
                                    .toList())),
                        ],
                      )),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    getRelativeTime(post.createdAt),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
            ),
            width: 98,
            height: 106,
            child: const Center(child: Text('이미지')),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/date_parser.dart';
import 'package:lets_jam/utils/helper.dart';
import 'package:lets_jam/widgets/post_badge.dart';

class PostThumbnail extends StatelessWidget {
  final PostModel post;

  const PostThumbnail({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: ColorSeed.boldOrangeStrong.color),
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
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  SizedBox(
                      height: 28,
                      child: Row(
                        children: [
                          PostBadge(
                              text: formatList(post.sessions
                                  .map((session) => sessionMap[session])
                                  .toList())),
                          const SizedBox(
                            width: 4,
                          ),
                          if (post.regions != null)
                            PostBadge(text: formatList(post.regions!)),
                          const SizedBox(
                            width: 4,
                          ),
                          PostBadge(
                              text: formatList(post.levels
                                  .map((level) => levelMap[level])
                                  .toList())),
                          const SizedBox(
                            width: 4,
                          ),
                        ],
                      )),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    getRelativeTime(post.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
            ),
            child: Center(
                child: post.images != null
                    ? Image.network(post.images![0],
                        width: 104, height: 104, fit: BoxFit.cover)
                    : Image.asset(
                        'assets/images/jam_temp_filled.png',
                      )),
          ),
        ],
      ),
    );
  }
}

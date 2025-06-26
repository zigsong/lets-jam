import 'package:flutter/material.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/date_parser.dart';
import 'package:lets_jam/utils/helper.dart';
import 'package:lets_jam/widgets/post_badge.dart';
import 'package:lets_jam/widgets/post_like_button.dart';

class PostThumbnail extends StatelessWidget {
  final PostModel post;
  final bool? withLikedTag;

  const PostThumbnail({super.key, required this.post, this.withLikedTag});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: ColorSeed.boldOrangeStrong.color),
          borderRadius: BorderRadius.circular(8)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  if (withLikedTag == true)
                    Positioned(
                      top: 10,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(18, 2, 10, 2),
                        decoration: BoxDecoration(
                          color: post.postType == PostTypeEnum.findBand
                              ? Colors.white
                              : ColorSeed.boldOrangeStrong.color,
                          border: post.postType == PostTypeEnum.findBand
                              ? Border(
                                  top: BorderSide(
                                      color: ColorSeed.boldOrangeStrong.color),
                                  right: BorderSide(
                                      color: ColorSeed.boldOrangeStrong.color),
                                  bottom: BorderSide(
                                      color: ColorSeed.boldOrangeStrong.color),
                                )
                              : null,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Text(
                          post.postType == PostTypeEnum.findBand ? '밴드' : '멤버',
                          style: TextStyle(
                              color: post.postType == PostTypeEnum.findBand
                                  ? ColorSeed.boldOrangeStrong.color
                                  : Colors.white),
                        ),
                      ),
                    ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            if (withLikedTag == true)
                              const SizedBox(
                                width: 44,
                              ),
                            Expanded(
                              child: Text(
                                post.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Wrap(
                          runSpacing: 4,
                          children: [
                            PostBadge(
                                text: formatList(post.sessions
                                    .map((session) => sessionMap[session])
                                    .toList())),
                            const SizedBox(
                              width: 4,
                            ),
                            if (post.regions != null &&
                                post.regions!.isNotEmpty)
                              PostBadge(text: formatList(post.regions!)),
                            const SizedBox(
                              width: 4,
                            ),
                            if (post.levels.isNotEmpty)
                              PostBadge(
                                  text: formatList(post.levels
                                      .map((level) => levelMap[level])
                                      .toList())),
                            const SizedBox(
                              width: 4,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          getRelativeTime(post.createdAt),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  color: Color(0xffD9D9D9),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  )),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: Stack(children: [
                  Center(
                      child: (post.images?.length ?? 0) > 0
                          ? Image.network(post.images![0],
                              width: 104, height: 104, fit: BoxFit.cover)
                          : Image.asset(
                              'assets/images/jam_temp_filled.png',
                              width: 104,
                              height: 104,
                            )),
                  Positioned(
                      top: 10,
                      right: 10,
                      child: PostLikeButton(
                        postId: post.id,
                        size: PostLikeButtonSize.sm,
                      ))
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

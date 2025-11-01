import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/date_parser.dart';
import 'package:lets_jam/utils/helper.dart';
import 'package:lets_jam/widgets/post_badge.dart';
import 'package:lets_jam/widgets/post_like_button.dart';

class PostThumbnail extends StatelessWidget {
  final PostModel post;
  final bool? withPrefixTag;

  const PostThumbnail({super.key, required this.post, this.withPrefixTag});

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
              flex: 7,
              child: Stack(
                children: [
                  if (withPrefixTag == true)
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
                            if (withPrefixTag == true)
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
                        SizedBox(
                          height: withPrefixTag == true ? 12 : 6,
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
                              PostBadge(
                                  text: formatList(post.regions!
                                      .map((region) => region.displayName)
                                      .toList())),
                            const SizedBox(
                              width: 4,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        (post.tags != null && post.tags!.isNotEmpty)
                            ? Row(
                                children: post.tags!
                                    .map((tag) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 6),
                                          child: Text(
                                            '#$tag',
                                            style: TextStyle(
                                                color: ColorSeed
                                                    .organizedBlackLight.color,
                                                fontSize: 12),
                                          ),
                                        ))
                                    .toList(),
                              )
                            : const SizedBox(height: 12),
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
            Flexible(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                ),
                child: Stack(children: [
                  Positioned.fill(
                    child: (post.images?.isNotEmpty ?? false)
                        ? Image.network(
                            post.images![0],
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          )
                        : Image.asset(
                            'assets/images/jam_temp_filled.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                  ),
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

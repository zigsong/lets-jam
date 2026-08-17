import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lets_jam/controllers/explore_filter_controller.dart';
import 'package:lets_jam/controllers/explore_posts_controller.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/region_enum.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/screens/post_detail_screen/post_detail_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/post_thumbnail.dart';

class ExplorePosts extends StatelessWidget {
  final PostTypeEnum postType;

  ExplorePosts({super.key, required this.postType});

  final ExploreFilterController filterController =
      Get.find<ExploreFilterController>();
  final ExplorePostsController postsController =
      Get.find<ExplorePostsController>();

  List<PostModel> _filterPosts(List<PostModel> allPosts) {
    List<SessionEnum> sessions = filterController.sessions;
    List<District> expandedRegions = filterController.getExpandedRegions();

    return allPosts.where((post) {
      // regions 필터 적용
      if (expandedRegions.isNotEmpty) {
        // post의 regions 중 하나라도 expandedRegions에 포함되면 통과
        bool regionMatch = post.regions
                ?.any((postRegion) => expandedRegions.contains(postRegion)) ??
            false;

        if (!regionMatch) return false;
      }

      // sessions 필터 적용
      if (sessions.isNotEmpty) {
        bool sessionMatch =
            post.sessions.any((postSession) => sessions.contains(postSession));

        if (!sessionMatch) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        if (postsController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final typedPosts = postsController.posts
            .where((post) => post.postType == postType)
            .toList();
        final filteredPosts = _filterPosts(typedPosts);

        if (filteredPosts.isEmpty) {
          return Center(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/empty_post.png',
                    width: 138,
                  ),
                  Text(
                    '찾고 있는 게시글이 없어요',
                    style: TextStyle(
                        fontSize: 15, color: ColorSeed.boldOrangeMedium.color),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFFFF6B2C),
          onRefresh: () => postsController.fetchPosts(),
          child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: filteredPosts.length,
              separatorBuilder: (context, index) => const SizedBox(
                    height: 8,
                  ),
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return GestureDetector(
                  child: PostThumbnail(post: post),
                  onTap: () async {
                    final deleted = await Navigator.push(
                        context,
                        Platform.isIOS
                            ? CupertinoPageRoute(
                                settings: const RouteSettings(
                                    name: 'PostDetailScreen'),
                                builder: (context) => PostDetailScreen(
                                      postId: post.id,
                                      userId: post.userId,
                                    ))
                            : MaterialPageRoute(
                                settings: const RouteSettings(
                                    name: 'PostDetailScreen'),
                                builder: (context) => PostDetailScreen(
                                      postId: post.id,
                                      userId: post.userId,
                                    )));

                    if (deleted == true) {
                      postsController.fetchPosts();
                    }
                  },
                );
              }),
        );
      }),
    );
  }
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lets_jam/controllers/explore_filter_controller.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/post_detail_screen.dart';
import 'package:lets_jam/widgets/post_thumbnail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExplorePosts extends StatefulWidget {
  final PageController pageController;

  const ExplorePosts({
    super.key,
    required this.pageController,
  });

  @override
  State<ExplorePosts> createState() => _ExplorePostsState();
}

class _ExplorePostsState extends State<ExplorePosts> {
  final ExploreFilterController exploreFilterController =
      Get.put(ExploreFilterController());

  Future<List<PostModel>> fetchPosts() async {
    final response = await Supabase.instance.client.from('posts').select('*');

    return response.map<PostModel>((json) => PostModel.fromJson(json)).toList();
  }

  _filterPosts(List<PostModel> posts) {
    return posts.where((post) {
      bool matchLevels = exploreFilterController.levels.isEmpty ||
          post.levels
              .any((level) => exploreFilterController.levels.contains(level));

      bool matchSessions = exploreFilterController.sessions.isEmpty ||
          post.sessions.any(
              (session) => exploreFilterController.sessions.contains(session));

      bool matchRegions = exploreFilterController.regions.isEmpty ||
          (post.regions?.any((region) =>
                  exploreFilterController.regions.contains(region)) ??
              false);

      return matchLevels && matchSessions && matchRegions;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchPosts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;
        final findBandPosts = posts
            .where((post) => post.postType == PostTypeEnum.findBand)
            .toList();
        final findSessionPosts = posts
            .where((post) => post.postType == PostTypeEnum.findSession)
            .toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PageView(
            controller: widget.pageController,
            physics: const NeverScrollableScrollPhysics(), // 기본 슬라이드 동작을 막음
            children: [
              Obx(() {
                final filteredPosts = _filterPosts(findSessionPosts);

                return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: filteredPosts.length,
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 8,
                        ),
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      return GestureDetector(
                        child: PostThumbnail(post: post),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  PostDetailScreen(post: post)));
                        },
                      );
                    });
              }),
              Obx(() {
                final filteredPosts = _filterPosts(findBandPosts);

                return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: filteredPosts.length,
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 8,
                        ),
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      return GestureDetector(
                        child: PostThumbnail(post: post),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  PostDetailScreen(post: post)));
                        },
                      );
                    });
              })
            ],
          ),
        );
      },
    );
  }
}

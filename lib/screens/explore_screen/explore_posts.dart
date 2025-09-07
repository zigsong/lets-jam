import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lets_jam/controllers/explore_filter_controller.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/post_detail_screen/post_detail_screen.dart';
import 'package:lets_jam/widgets/post_thumbnail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExplorePosts extends StatefulWidget {
  final PostTypeEnum postType;
  final void Function(void Function()) onReloadRegister;

  const ExplorePosts(
      {super.key, required this.postType, required this.onReloadRegister});

  @override
  State<ExplorePosts> createState() => _ExplorePostsState();
}

class _ExplorePostsState extends State<ExplorePosts> {
  late Future<List<PostModel>> _posts;

  final ExploreFilterController exploreFilterController =
      Get.put(ExploreFilterController());

  @override
  void initState() {
    super.initState();

    widget.onReloadRegister(_fetchPosts);
    _posts = _fetchPosts();
  }

  Future<List<PostModel>> _fetchPosts() async {
    final response = await Supabase.instance.client
        .from('posts')
        .select('*')
        .order('created_at', ascending: false);

    print('기본 데이터: $response');

    return response.map<PostModel>((json) => PostModel.fromJson(json)).toList();
  }

  _filterPosts(List<PostModel> posts) {
    return posts.where((post) {
      bool matchSessions = exploreFilterController.sessions.isEmpty ||
          post.sessions.any(
              (session) => exploreFilterController.sessions.contains(session));

      bool matchRegions = exploreFilterController.regions.isEmpty ||
          (post.regions?.any((region) =>
                  exploreFilterController.regions.contains(region)) ??
              false);

      return matchSessions && matchRegions;
    }).toList();
  }

  void _refresh() {
    setState(() {
      _posts = _fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _posts,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;
        final findBandPosts = posts
            .where((post) => post.postType == PostTypeEnum.findBand)
            .toList();
        final findSessionPosts = posts
            .where((post) => post.postType == PostTypeEnum.findMember)
            .toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(() {
            final filteredPosts = widget.postType == PostTypeEnum.findBand
                ? _filterPosts(findSessionPosts)
                : _filterPosts(findBandPosts);

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
                    onTap: () async {
                      final deleted = await Navigator.push(
                          context,
                          Platform.isIOS
                              ? CupertinoPageRoute(
                                  builder: (context) => PostDetailScreen(
                                        postId: post.id,
                                        userId: post.userId,
                                      ))
                              : MaterialPageRoute(
                                  builder: (context) => PostDetailScreen(
                                        postId: post.id,
                                        userId: post.userId,
                                      )));

                      /** @zigsong TODO: 화면 다시 fetch하기 */
                      if (deleted == true) {
                        _refresh();
                      }
                    },
                  );
                });
          }),
        );
      },
    );
  }
}

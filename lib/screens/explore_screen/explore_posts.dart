import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lets_jam/controllers/explore_filter_controller.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/region_enum.dart';
import 'package:lets_jam/models/session_enum.dart';
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

  final ExploreFilterController filterController =
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

    return response.map<PostModel>((json) => PostModel.fromJson(json)).toList();
  }

  _filterPosts(List<PostModel> allPosts) {
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

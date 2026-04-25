import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/post_detail_screen/post_detail_screen.dart';
import 'package:lets_jam/widgets/post_thumbnail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LikedPosts extends StatefulWidget {
  const LikedPosts({
    super.key,
  });

  @override
  State<LikedPosts> createState() => _LikedPostsState();
}

class _LikedPostsState extends State<LikedPosts> {
  late Future<List<PostModel>> _posts;
  final SessionController sessionController = Get.find<SessionController>();

  @override
  void initState() {
    super.initState();

    _posts = _fetchLikedPosts();
  }

  Future<List<PostModel>> _fetchLikedPosts() async {
    final user = sessionController.user.value;

    if (user == null) return [];

    final supabase = Supabase.instance.client;

    final blockedResponse = await supabase
        .from('blocked_users')
        .select('blocked_id')
        .eq('blocker_id', user.id);
    final blockedIds = blockedResponse
        .map<String>((row) => row['blocked_id'] as String)
        .toList();

    final response = await supabase
        .from('post_likes')
        .select('posts(*, comment_count:comments!left(id))')
        .eq('user_id', user.id)
        .order('liked_at', ascending: false);

    return response
        .map<PostModel>((json) => PostModel.fromJson(json['posts']))
        .where((post) => !blockedIds.contains(post.userId))
        .toList();
  }

  void _refresh() {
    setState(() {
      _posts = _fetchLikedPosts();
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

        if (posts.isEmpty) {
          return const Center(
            child: Text(
              '아직 찜한 게시글이 없어요',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          );
        }

        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: posts.length,
                separatorBuilder: (context, index) => const SizedBox(
                      height: 8,
                    ),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return GestureDetector(
                    child: PostThumbnail(
                      post: post,
                      withPrefixTag: true,
                    ),
                    onTap: () async {
                      final deleted = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostDetailScreen(
                                    postId: post.id,
                                    userId: post.userId,
                                  )));

                      if (deleted == true) {
                        _refresh();
                      }
                    },
                  );
                }));
      },
    );
  }
}

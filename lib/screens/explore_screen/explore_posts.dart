import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/post_detail_screen.dart';
import 'package:lets_jam/widgets/post_thumbnail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExplorePosts extends StatelessWidget {
  final PageController pageController;

  const ExplorePosts({super.key, required this.pageController});

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final posts = await Supabase.instance.client.from('posts').select('*');

    return posts;
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
            .where((post) =>
                PostModel.fromJson(post).postType == PostTypeEnum.findBand)
            .toList();
        final findSessionPosts = posts
            .where((post) =>
                PostModel.fromJson(post).postType == PostTypeEnum.findSession)
            .toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(), // 기본 슬라이드 동작을 막음
            children: [
              ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: findSessionPosts.length,
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 8,
                      ),
                  itemBuilder: (context, index) {
                    final post = findSessionPosts[index];
                    return GestureDetector(
                      child: PostThumbnail(post: PostModel.fromJson(post)),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PostDetailScreen(
                                post: PostModel.fromJson(post))));
                      },
                    );
                  }),
              ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: findBandPosts.length,
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 8,
                      ),
                  itemBuilder: (context, index) {
                    final post = findBandPosts[index];
                    return GestureDetector(
                      child: PostThumbnail(post: PostModel.fromJson(post)),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PostDetailScreen(
                                post: PostModel.fromJson(post))));
                      },
                    );
                  })
            ],
          ),
        );
      },
    );
  }
}

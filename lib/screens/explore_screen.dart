import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/post_detail_screen.dart';
import 'package:lets_jam/widgets/page_toggler.dart';
import 'package:lets_jam/widgets/post_thumbnail.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PageController _pageViewController = PageController();

  int _selectedPage = 0;

  void _slidePage() {
    setState(() {
      _selectedPage = _selectedPage == 0 ? 1 : 0;
    });

    _pageViewController.animateToPage(
      _selectedPage,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final posts = await Supabase.instance.client.from('posts').select('*');

    return posts;
  }

  @override
  Widget build(BuildContext context) {
    var isBandTabSelected = _selectedPage == 0;
    var isMemberTabSelected = _selectedPage == 1;

    var mockFilteredTags = ['태그1', '태그22', '태그333'];

    return Scaffold(
        body: Column(
      children: [
        Stack(
          children: [
            PageToggler(
              onTap: _slidePage,
              selectedIndex: isBandTabSelected ? 0 : 1,
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: IconButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero, // 패딩 설정
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.notifications_outlined)),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              SizedBox(
                  width: 36,
                  child: SvgPicture.asset('assets/icons/filter.svg')),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(mockFilteredTags.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Tag(text: mockFilteredTags[index]),
                        );
                      }),
                    )),
              ),
            ],
          ),
        ),
        const Divider(
          height: 0,
          thickness: 2,
          color: Color(0xffD9D9D9),
        ),
        Expanded(
          child: FutureBuilder(
            future: fetchPosts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final posts = snapshot.data!;
              final findBandPosts = posts
                  .where((post) =>
                      PostModel.fromJson(post).postType ==
                      PostTypeEnum.findBand)
                  .toList();
              final findSessionPosts = posts
                  .where((post) =>
                      PostModel.fromJson(post).postType ==
                      PostTypeEnum.findSession)
                  .toList();

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: PageView(
                  controller: _pageViewController,
                  physics:
                      const NeverScrollableScrollPhysics(), // 기본 슬라이드 동작을 막음
                  children: [
                    ListView.separated(
                        itemCount: findSessionPosts.length,
                        separatorBuilder: (context, index) => const SizedBox(
                              height: 8,
                            ),
                        itemBuilder: (context, index) {
                          final post = findSessionPosts[index];
                          return GestureDetector(
                            child:
                                PostThumbnail(post: PostModel.fromJson(post)),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PostDetailScreen(
                                      post: PostModel.fromJson(post))));
                            },
                          );
                        }),
                    ListView.separated(
                        itemCount: findBandPosts.length,
                        separatorBuilder: (context, index) => const SizedBox(
                              height: 8,
                            ),
                        itemBuilder: (context, index) {
                          final post = findBandPosts[index];
                          return GestureDetector(
                            child:
                                PostThumbnail(post: PostModel.fromJson(post)),
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
          ),
        )
      ],
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/post_detail_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/filter_tag.dart';
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
    var mockFilteredTags = ['태그1', '태그22', '태그333'];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      /** 상태바 아이콘 색상 */
      value: !isBandTabSelected
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Column(
        children: [
          Container(
              height: 102,
              decoration: BoxDecoration(
                  color: isBandTabSelected
                      ? ColorSeed.boldOrangeStrong.color
                      : Colors.transparent),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          width: 25,
                          height: 30,
                          child: isBandTabSelected
                              ? Image.asset('assets/images/logo_sm_white.png')
                              : Image.asset(
                                  'assets/images/logo_sm_orange.png')),
                      PageToggler(
                        selectedIndex: _selectedPage,
                        onTap: _slidePage,
                      ),
                      SizedBox(
                          width: 28,
                          height: 28,
                          child: isBandTabSelected
                              ? Image.asset('assets/icons/bell_white.png')
                              : Image.asset('assets/icons/bell_active.png')),
                    ],
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                    width: 20,
                    child: Image.asset('assets/icons/filter_active.png')),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            List.generate(mockFilteredTags.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FilterTag(text: mockFilteredTags[index]),
                          );
                        }),
                      )),
                ),
              ],
            ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PageView(
                    controller: _pageViewController,
                    physics:
                        const NeverScrollableScrollPhysics(), // 기본 슬라이드 동작을 막음
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
                          padding: EdgeInsets.zero,
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
      ),
    );
  }
}

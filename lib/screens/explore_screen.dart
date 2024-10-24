import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_jam/models/post_model.dart';
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
  final _posts = Supabase.instance.client.from('posts').select('*');
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
          child: PageView(
            controller: _pageViewController,
            physics: const NeverScrollableScrollPhysics(), // 기본 슬라이드 동작을 막음
            children: [
              FutureBuilder(
                future: _posts,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final posts = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: ListView.separated(
                        itemCount: posts.length,
                        separatorBuilder: (context, index) => const SizedBox(
                              height: 8,
                            ),
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return PostThumbnail(post: PostModel.fromJson(post));
                        }),
                  );
                },
              ),
              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              //   child: ListView.separated(
              //       itemCount: 10,
              //       separatorBuilder: (context, index) => const SizedBox(
              //             height: 12,
              //           ),
              //       itemBuilder: (context, index) {
              //         return const PostThumbnail(title: '멤버찾기');
              //       }),
              // )
            ],
          ),
        )
      ],
    ));
  }
}

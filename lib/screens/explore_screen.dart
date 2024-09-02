import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final posts = Supabase.instance.client.from('posts').select('*');
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

    return Scaffold(
        body: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _slidePage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 32,
                    width: 160,
                    decoration: BoxDecoration(
                        color: const Color(0xffefeff0),
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 100),
                    left: isBandTabSelected ? 0 : 76,
                    child: Container(
                      alignment: Alignment.center,
                      height: 32,
                      width: 84,
                      decoration: BoxDecoration(
                        color: const Color(0xffffb4b4),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '밴드찾기',
                        style: TextStyle(
                            color: isBandTabSelected
                                ? Colors.white
                                : const Color(0xffafb1b6)),
                      ),
                      const SizedBox(
                        width: 28,
                      ),
                      Text(
                        '멤버찾기',
                        style: TextStyle(
                            color: isMemberTabSelected
                                ? Colors.white
                                : const Color(0xffafb1b6)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: PageView(
            controller: _pageViewController,
            physics: const NeverScrollableScrollPhysics(), // 기본 슬라이드 동작을 막음
            children: const [
              Center(
                child: Text('밴드를 찾아보세요!'),
              ),
              Center(
                child: Text('멤버를 찾아보세요!'),
              )
            ],
          ),
        )
      ],
    ));
  }
}

class ExploreBandContent extends StatefulWidget {
  const ExploreBandContent({super.key});

  @override
  State<ExploreBandContent> createState() => _ExploreBandContentState();
}

class _ExploreBandContentState extends State<ExploreBandContent> {
  final posts = Supabase.instance.client.from('posts').select('*');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: posts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!;
          return ListView.builder(
              itemCount: posts.length,
              itemBuilder: ((context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post['title']),
                );
              }));
        });
  }
}

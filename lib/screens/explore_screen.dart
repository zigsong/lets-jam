import 'package:flutter/material.dart';
import 'package:lets_jam/widgets/page_toggler.dart';
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

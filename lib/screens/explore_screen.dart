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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(children: [
          TabBar(
            tabs: const [
              Tab(text: "밴드찾기"),
              Tab(text: "멤버찾기"),
            ],
            labelColor: Colors.amber[700],
            dividerColor: Colors.amber[700],
            indicatorColor: Colors.amber[700],
            unselectedLabelColor: Colors.grey,
          ),
          const Expanded(
            child: TabBarView(children: [
              // ExploreBandContent(),
              Center(child: Text("밴드를 찾아보세요")),
              Center(child: Text("멤버를 찾아보세요")),
            ]),
          )
        ]),
      ),
    );
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

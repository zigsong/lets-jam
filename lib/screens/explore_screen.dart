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
    return Scaffold(
        body: FutureBuilder(
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
            }));
  }
}

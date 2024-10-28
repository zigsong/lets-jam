import 'package:flutter/material.dart';

enum PostTypeEnum { findBand, findSession }

Map<PostTypeEnum, String> postTypeTitle = {
  PostTypeEnum.findBand: '밴드',
  PostTypeEnum.findSession: '세션',
};

class PostScreen extends StatefulWidget {
  final PostTypeEnum postType;
  const PostScreen({super.key, required this.postType});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${postTypeTitle[widget.postType]} 구하기',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: const Color(0xffF2F2F2),
      ),
    );
  }
}

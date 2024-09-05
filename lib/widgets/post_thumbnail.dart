import 'package:flutter/material.dart';

class PostThumbnail extends StatelessWidget {
  final String title;

  const PostThumbnail({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: const Color(0xffEFEFF0)),
          borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(title),
      ),
    );
  }
}

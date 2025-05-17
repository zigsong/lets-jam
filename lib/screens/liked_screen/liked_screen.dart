import 'package:flutter/material.dart';
import 'package:lets_jam/screens/liked_screen/liked_posts.dart';

class LikedScreen extends StatefulWidget {
  const LikedScreen({super.key});

  @override
  State<LikedScreen> createState() => _LikedScreenState();
}

class _LikedScreenState extends State<LikedScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '내가 찜한 글',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              SizedBox(
                  width: 28,
                  height: 28,
                  child: Image.asset('assets/icons/bell_active.png')),
            ],
          ),
        ),
        const SizedBox(
          height: 14.5,
        ),
        const Expanded(
          child: Stack(children: [
            LikedPosts(),
          ]),
        )
      ]),
    );
  }
}

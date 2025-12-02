import 'package:flutter/material.dart';
import 'package:lets_jam/screens/alarm_screen.dart';
import 'package:lets_jam/screens/liked_screen/liked_posts.dart';
import 'package:lets_jam/screens/settings_screen/settings_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

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
              Text(
                '내가 찜한 글',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: ColorSeed.boldOrangeMedium.color),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const AlarmScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 2),
                      child: SizedBox(
                          width: 28,
                          height: 28,
                          child: Image.asset('assets/icons/bell_orange.png')),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const SettingsScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 2),
                      child: SizedBox(
                          width: 28,
                          height: 28,
                          child: Image.asset('assets/icons/settings.png')),
                    ),
                  ),
                ],
              ),
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

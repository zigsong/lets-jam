import 'package:flutter/material.dart';
import 'package:lets_jam/screens/alarm_screen.dart';
import 'package:lets_jam/screens/liked_screen/liked_posts.dart';
import 'package:lets_jam/screens/liked_screen/liked_studios.dart';
import 'package:lets_jam/screens/settings_screen/settings_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class LikedScreen extends StatefulWidget {
  const LikedScreen({super.key});

  @override
  State<LikedScreen> createState() => _LikedScreenState();
}

class _LikedScreenState extends State<LikedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        const SizedBox(height: 8),
        PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: TabBar(
            controller: _tabController,
            labelColor: ColorSeed.boldOrangeMedium.color,
            unselectedLabelColor: ColorSeed.meticulousGrayMedium.color,
            indicatorColor: ColorSeed.boldOrangeMedium.color,
            indicatorWeight: 2.0,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Container(
                height: 36,
                alignment: Alignment.center,
                child: const Text(
                  '밴드/멤버 구하기',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                height: 36,
                alignment: Alignment.center,
                child: const Text(
                  '합주실',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              LikedPosts(),
              LikedStudios(),
            ],
          ),
        ),
      ]),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lets_jam/screens/band_screen.dart';
import 'package:lets_jam/screens/profile_screen/profile_screen.dart';
import 'package:lets_jam/screens/explore_screen/explore_screen.dart';
import 'package:lets_jam/screens/liked_screen/liked_screen.dart';
import 'package:lets_jam/screens/upload_screen/upload_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/bottom_app_bar_item.dart';

class DefaultNavigation extends StatefulWidget {
  final int? fromIndex;
  const DefaultNavigation({super.key, this.fromIndex});

  @override
  State<DefaultNavigation> createState() => _DefaultNavigationState();
}

class _DefaultNavigationState extends State<DefaultNavigation> {
  int _selectedIndex = 0;
  final bool _isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.fromIndex ?? 0;
  }

  final List<Widget> _widgetOptions = <Widget>[
    const ExploreScreen(),
    const LikedScreen(),
    const BandScreen(),
    const ProfileScreen(),
  ];

  void _onHomeButtonTapped() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  void _onLikeButtonTapped() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _onProfileButtonTapped() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
          Positioned.fill(
              child: Center(child: _widgetOptions.elementAt(_selectedIndex))),
        ]),
        bottomNavigationBar: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: ColorSeed.meticulousGrayLight.color,
                        width: 1.0)),
              ),
              child: BottomAppBar(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
                height: 72,
                color: Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    BottomAppBarItem(
                        isActive: _selectedIndex == 0,
                        defaultIcon: Image.asset(
                            'assets/icons/bottom_nav/home_default.png'),
                        activeIcon: Image.asset(
                            'assets/icons/bottom_nav/home_active.png'),
                        label: '홈',
                        onPressed: _onHomeButtonTapped),
                    BottomAppBarItem(
                        isActive: _selectedIndex == 1,
                        defaultIcon: Image.asset(
                            'assets/icons/bottom_nav/like_default.png'),
                        activeIcon: Image.asset(
                            'assets/icons/bottom_nav/like_active.png'),
                        label: '찜',
                        onPressed: _onLikeButtonTapped),
                    // BottomAppBarItem(
                    //     isActive: _selectedIndex == 2,
                    //     defaultIcon: Image.asset(
                    //         'assets/icons/bottom_nav/band_default.png'),
                    //     activeIcon: Image.asset(
                    //         'assets/icons/bottom_nav/band_active.png'),
                    //     label: '밴드',
                    //     onPressed: _onBandButtonTapped),
                    BottomAppBarItem(
                        isActive: _selectedIndex == 2,
                        defaultIcon: Image.asset(
                            'assets/icons/bottom_nav/profile_default.png'),
                        activeIcon: Image.asset(
                            'assets/icons/bottom_nav/profile_active.png'),
                        label: '프로필',
                        onPressed: _onProfileButtonTapped),
                    Semantics(
                      label: '게시글 추가 버튼',
                      button: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: BottomAppBarItem(
                            isActive: _selectedIndex == 3,
                            defaultIcon: Image.asset(
                                'assets/icons/bottom_nav/add_default.png'),
                            activeIcon: Image.asset(
                                'assets/icons/bottom_nav/add_active.png'),
                            label: '글쓰기',
                            onPressed: _onLikeButtonTapped),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                top: -16,
                right: 30,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        backgroundColor: ColorSeed.boldOrangeStrong.color,
                        elevation: 0),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const UploadScreen(),
                        ),
                      );
                    },
                    child: Transform.rotate(
                        angle: _isBottomSheetOpen ? 45 * pi / 180 : 0,
                        child: SizedBox(
                            width: 28,
                            height: 28,
                            child: Image.asset(
                                'assets/icons/bottom_nav/add_white.png'))),
                  ),
                ))
          ],
        ));
  }
}

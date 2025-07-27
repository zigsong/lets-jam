import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lets_jam/screens/band_screen.dart';
import 'package:lets_jam/screens/profile_screen/profile_screen.dart';
import 'package:lets_jam/screens/explore_screen/explore_screen.dart';
import 'package:lets_jam/screens/liked_screen/liked_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/bottom_app_bar_item.dart';
import 'package:lets_jam/widgets/post_bottom_sheet.dart';

class DefaultNavigation extends StatefulWidget {
  final int? fromIndex;
  const DefaultNavigation({super.key, this.fromIndex});

  @override
  State<DefaultNavigation> createState() => _DefaultNavigationState();
}

class _DefaultNavigationState extends State<DefaultNavigation>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Offset>? _offsetAnimation;
  int _selectedIndex = 0;
  bool _isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.fromIndex ?? 0;
    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // 아래에서 시작
      end: const Offset(0.0, 0.0), // 제자리로 이동
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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

  void _onBandButtonTapped() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  void _onProfileButtonTapped() {
    setState(() {
      _selectedIndex = 3;
    });
  }

  void _toggleBottomSheet() {
    if (_isBottomSheetOpen) {
      _controller!.reverse();
    } else {
      _controller!.forward();
    }
    setState(() {
      _isBottomSheetOpen = !_isBottomSheetOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
          Positioned.fill(
              child: Center(child: _widgetOptions.elementAt(_selectedIndex))),
          // dimmed 배경
          if (_isBottomSheetOpen)
            GestureDetector(
              onTap: _toggleBottomSheet,
              child: AnimatedOpacity(
                opacity: _isBottomSheetOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.grey,
                ),
              ),
            ),
          // BottomSheet
          if (_isBottomSheetOpen)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _offsetAnimation!,
                child: GestureDetector(
                  onTap: () {
                    // BottomSheet 동작
                  },
                  child: PostBottomSheet(onClose: () {
                    _controller!.reverse();
                    setState(() {
                      _isBottomSheetOpen = !_isBottomSheetOpen;
                    });
                  }),
                ),
              ),
            ),
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
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                height: 84,
                color: Colors.white,
                /** MARK: 있으나 없으나? */
                // shape: const CircularNotchedRectangle(),
                notchMargin: 5,
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
                    // MARK: AppBarItem 4개의 간격을 조정하기 위한 조치
                    Semantics(
                      label: '게시글 추가 버튼',
                      button: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: BottomAppBarItem(
                            isActive: _selectedIndex == 2,
                            defaultIcon: Image.asset(
                                'assets/icons/bottom_nav/add_default.png'),
                            activeIcon: Image.asset(
                                'assets/icons/bottom_nav/add_active.png'),
                            label: '',
                            onPressed: _onLikeButtonTapped),
                      ),
                    ),
                    BottomAppBarItem(
                        isActive: _selectedIndex == 2,
                        defaultIcon: Image.asset(
                            'assets/icons/bottom_nav/band_default.png'),
                        activeIcon: Image.asset(
                            'assets/icons/bottom_nav/band_active.png'),
                        label: '밴드',
                        onPressed: _onBandButtonTapped),
                    BottomAppBarItem(
                        isActive: _selectedIndex == 3,
                        defaultIcon: Image.asset(
                            'assets/icons/bottom_nav/profile_default.png'),
                        activeIcon: Image.asset(
                            'assets/icons/bottom_nav/profile_active.png'),
                        label: '프로필',
                        onPressed: _onProfileButtonTapped),
                  ],
                ),
              ),
            ),
            Positioned(
                top: -14,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10.5),
                      backgroundColor: ColorSeed.boldOrangeStrong.color,
                      elevation: 0),
                  onPressed: _toggleBottomSheet,
                  child: Transform.rotate(
                      angle: _isBottomSheetOpen ? 45 * pi / 180 : 0,
                      child: SizedBox(
                          width: 44,
                          child: Image.asset(
                              'assets/icons/bottom_nav/add_white.png'))),
                ))
          ],
        ));
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';

import 'package:lets_jam/screens/profile_screen/profile_screen.dart';
import 'package:lets_jam/screens/profile_screen/profile_upload_screen.dart';
import 'package:lets_jam/screens/explore_screen/explore_screen.dart';
import 'package:lets_jam/screens/liked_screen/liked_screen.dart';
import 'package:lets_jam/screens/upload_screen/upload_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/bottom_app_bar_item.dart';
import 'package:lets_jam/widgets/modal.dart';

class DefaultNavigation extends StatefulWidget {
  final int? fromIndex;
  const DefaultNavigation({super.key, this.fromIndex});

  @override
  State<DefaultNavigation> createState() => _DefaultNavigationState();
}

class _DefaultNavigationState extends State<DefaultNavigation> {
  int _selectedIndex = 0;
  final bool _isBottomSheetOpen = false;
  final SessionController sessionController = Get.find<SessionController>();

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.fromIndex ?? 0;
  }

  final List<Widget> _widgetOptions = <Widget>[
    const ExploreScreen(),
    const LikedScreen(),
    // const BandScreen(),
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
    if (sessionController.hasProfile.value == false) {
      showModal(
        context: context,
        desc: '프로필 작성 후에 이용할 수 있어요.\n프로필을 작성하러 갈까요?',
        confirmText: '작성하기',
        onConfirm: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const ProfileUploadScreen(),
          ));
        },
        cancelText: '다음에 할게요',
      );
    } else {
      setState(() {
        _selectedIndex = 2;
      });
    }
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
                height: 66,
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
                            onPressed: () {}),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                top: -20,
                right: 28,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent, // 빈
                      onTap: () {
                        if (sessionController.isLoggedIn.value == false) {
                          showModal(
                              context: context,
                              desc: '로그인 후에 이용할 수 있어요',
                              confirmText: '로그인',
                              onConfirm: () {
                                sessionController.signIn();
                              },
                              cancelText: '다음에 할게요',
                              onCancel: null);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const UploadScreen(),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorSeed.boldOrangeStrong.color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Transform.rotate(
                              angle: _isBottomSheetOpen ? 45 * pi / 180 : 0,
                              child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: Image.asset(
                                      'assets/icons/bottom_nav/add_white.png'))),
                        ),
                      ),
                    ),
                  ),
                ))
          ],
        ));
  }
}

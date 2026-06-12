import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/screens/profile_screen/profile_screen.dart';
import 'package:lets_jam/screens/explore_screen/explore_screen.dart';
import 'package:lets_jam/screens/liked_screen/liked_screen.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/post_detail_screen/post_detail_screen.dart';
import 'package:lets_jam/screens/upload_screen/post_form_screen.dart';
import 'package:lets_jam/screens/upload_screen/upload_post_screen.dart';
import 'package:lets_jam/utils/auth_guard.dart';
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
  final SessionController sessionController = Get.find<SessionController>();
  PostTypeEnum _writePostType = PostTypeEnum.findBand;
  void Function(PostTypeEnum)? _switchExploreTab;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.fromIndex ?? 0;
    _widgetOptions = <Widget>[
      ExploreScreen(
        onSwitchTabRegister: (fn) {
          _switchExploreTab = fn;
        },
        onTabChanged: (type) {
          _writePostType = type;
        },
      ),
      const LikedScreen(),
    ];
  }

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
    requireAuthAndProfile(context, onAuthorized: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
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
                        requireAuthAndProfile(context, onAuthorized: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  UploadPostScreen(postType: _writePostType),
                            ),
                          )
                              .then((result) {
                            if (!mounted) return;
                            if (result is CreatedPostResult) {
                              // 작성한 타입으로 탐색 탭을 전환해두고,
                              // 방금 만든 글의 상세 화면으로 이동
                              _switchExploreTab?.call(result.postType);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PostDetailScreen(
                                    postId: result.postId,
                                    userId: result.userId,
                                  ),
                                ),
                              );
                            }
                          });
                        });
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

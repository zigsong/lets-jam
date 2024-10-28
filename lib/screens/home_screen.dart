import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_jam/screens/explore_screen.dart';
import 'package:lets_jam/screens/profile_screen.dart';
import 'package:lets_jam/widgets/post_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  final int? fromIndex;
  const HomeScreen({super.key, this.fromIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
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
    const ExploreScreen(),
    const ProfileScreen(),
    const ProfileScreen()
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

  void _onAddButtonTapped() {
    print('포스팅 추가');
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
        /** @zigsong TODO: appbar height 정하기 */
        appBar: AppBar(
          toolbarHeight: 20,
        ),
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
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xffBFFFAF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: const PostBottomSheet(),
                  ),
                ),
              ),
            ),
        ]),
        bottomNavigationBar: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            BottomAppBar(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              height: 84,
              color: Colors.white,
              shape: const CircularNotchedRectangle(),
              notchMargin: 5,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  BottomAppBarItem(
                      icon: SvgPicture.asset('assets/icons/home.svg'),
                      label: '홈',
                      onPressed: _onHomeButtonTapped),
                  BottomAppBarItem(
                      icon: SvgPicture.asset('assets/icons/like.svg'),
                      label: '좋아요',
                      onPressed: _onLikeButtonTapped),
                  BottomAppBarItem(
                      icon: SvgPicture.asset('assets/icons/band-temp.svg'),
                      label: '',
                      onPressed: _onLikeButtonTapped),
                  BottomAppBarItem(
                      icon: SvgPicture.asset('assets/icons/band-temp.svg'),
                      label: '밴드',
                      onPressed: _onBandButtonTapped),
                  BottomAppBarItem(
                      icon: SvgPicture.asset('assets/icons/profile.svg'),
                      label: '프로필',
                      onPressed: _onProfileButtonTapped),
                ],
              ),
            ),
            Positioned(
                top: -12,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      side: const BorderSide(width: 3, color: Colors.white),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: const Color(0xffBFFFAF),
                      elevation: 0),
                  onPressed: _toggleBottomSheet,
                  child: Transform.rotate(
                      angle: _isBottomSheetOpen ? 45 * pi / 180 : 0,
                      child: SvgPicture.asset('assets/icons/add.svg')),
                ))
          ],
        ));
  }
}

class BottomAppBarItem extends StatefulWidget {
  final Widget icon;
  final String label;
  final Function() onPressed;

  const BottomAppBarItem(
      {super.key,
      required this.icon,
      required this.label,
      required this.onPressed});

  @override
  State<BottomAppBarItem> createState() => _BottomAppBarItemState();
}

class _BottomAppBarItemState extends State<BottomAppBarItem> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Column(
          children: <Widget>[
            widget.icon,
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

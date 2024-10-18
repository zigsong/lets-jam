import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_jam/screens/explore_screen.dart';
import 'package:lets_jam/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int? fromIndex;
  const HomeScreen({super.key, this.fromIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.fromIndex ?? 0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        /** @zigsong TODO: appbar height 정하기 */
        appBar: AppBar(
          toolbarHeight: 20,
        ),
        body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
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
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: const Color(0xffBFFFAF),
                      elevation: 0),
                  child: SvgPicture.asset('assets/icons/add.svg'),
                  onPressed: () {},
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

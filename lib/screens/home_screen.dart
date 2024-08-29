import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_jam/screens/explore_screen.dart';
import 'package:lets_jam/screens/post_screen.dart';
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
    const PostScreen(),
    const ProfileScreen()
  ];

  void _onHomeButtonTapped() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  void _onFilterButtonTapped() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _onProfileButtonTapped() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  void _onAddButtonTapped() {
    print('포스팅 추가');
  }

  @override
  Widget build(BuildContext context) {
    var isHomeSelected = _selectedIndex == 0;
    var isProfileSelected = _selectedIndex == 2;

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            "Let's JAM! 🍯",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
        floatingActionButton: FloatingActionButton(
          onPressed: _onAddButtonTapped,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          foregroundColor: Colors.grey[700],
          elevation: 2,
          backgroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          height: 90,
          color: Colors.white,
          shadowColor: Colors.grey[700],
          notchMargin: 5,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              BottomAppBarItem(
                icon: SvgPicture.asset('assets/icons/home.svg'),
                label: '홈',
                onPressed: _onHomeButtonTapped,
              ),
              BottomAppBarItem(
                icon: SvgPicture.asset('assets/icons/filter.svg'),
                label: '필터',
                onPressed: _onFilterButtonTapped,
              ),
              BottomAppBarItem(
                icon: SvgPicture.asset('assets/icons/profile.svg'),
                label: '프로필',
                onPressed: _onProfileButtonTapped,
              )
            ],
          ),
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

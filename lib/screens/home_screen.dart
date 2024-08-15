import 'package:flutter/material.dart';
import 'package:lets_jam/screens/explore_screen.dart';
import 'package:lets_jam/screens/post_screen.dart';
import 'package:lets_jam/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
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

  void _onAddButtonTapped() {
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
          foregroundColor: Colors.white,
          backgroundColor: Colors.amber[700],
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          height: 50,
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 5,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                  onPressed: _onHomeButtonTapped,
                  icon: Icon(Icons.home,
                      color: isHomeSelected ? Colors.amber[700] : Colors.grey)),
              IconButton(
                  onPressed: _onProfileButtonTapped,
                  icon: Icon(
                    Icons.person,
                    color: isProfileSelected ? Colors.amber[700] : Colors.grey,
                  ))
            ],
          ),
        ));
  }
}

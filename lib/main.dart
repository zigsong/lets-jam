import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const JamApp(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.amber[100],
        useMaterial3: true,
      ),
    );
  }
}

class JamApp extends StatefulWidget {
  const JamApp({super.key});

  @override
  State<JamApp> createState() => _JamAppState();
}

class _JamAppState extends State<JamApp> {
  int _selectedIndex = 0;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      '밴드찾기/멤버찾기',
      style: optionStyle,
    ),
    Text(
      '게시글 올리기',
      style: optionStyle,
    ),
    Text(
      '내 프로필',
      style: optionStyle,
    ),
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
          backgroundColor: Colors.amber[100],
          elevation: 0,
          title: const Text(
            "Let's JAM! 🍯",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // actions: [
          //   IconButton(
          //     visualDensity: const VisualDensity(horizontal: -4.0, vertical: 0),
          //     onPressed: () {},
          //     icon: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
          //   ),
          //   IconButton(
          //     visualDensity: const VisualDensity(horizontal: -4.0, vertical: 0),
          //     onPressed: () {},
          //     icon: Icon(Icons.settings_outlined, color: Colors.grey[700]),
          //   )
          // ],
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

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lets_jam/screens/explore_screen.dart';
import 'package:lets_jam/screens/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  KakaoSdk.init(
    nativeAppKey: dotenv.get("KAKAO_NATIVE_APP_KEY"),
    javaScriptAppKey: dotenv.get("KAKAO_JAVASCRIPT_APP_KEY"),
  );

  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

  final List<Widget> _widgetOptions = <Widget>[
    const ExploreScreen(),
    const Text(
      '게시글 올리기',
      style: optionStyle,
    ),
    const ProfileScreen()
    // const Text(
    //   '내 프로필',
    //   style: optionStyle,
    // ),
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

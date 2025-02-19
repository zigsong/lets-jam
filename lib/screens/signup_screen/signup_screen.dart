import 'package:flutter/material.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/models/signup_model.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:lets_jam/screens/signup_screen/post_profile_page.dart';
import 'package:lets_jam/utils/helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  final User user;

  const SignupScreen({super.key, required this.user});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  final SignupModel _signupData = SignupModel.init();

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  void _updateSessionLevel(SessionEnum key, LevelEnum value) {
    setState(() {
      _signupData.sessionLevel[key] = value;
    });
  }

  void _submit() {
    _saveUserToSupabase();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const DefaultNavigation(
              fromIndex: 2,
            )));
  }

  Future<void> _saveUserToSupabase() async {
    try {
      await Supabase.instance.client.from('users').insert({
        'email': widget.user.email,
        'nickname': _signupData.nickname,
        'sessions': _signupData.sessions.map((el) => el.name).toList(),
        'session_level': _signupData.sessionLevel.map(
            (key, value) => MapEntry(enumToString(key), enumToString(value))),
        'age': _signupData.age?.name,
        'contact': _signupData.contact,
        'profile_image': _signupData.profileImage?.path,
        'images': _signupData.images.map((image) => image.path).toList(),
        'bio': _signupData.bio,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입이 완료되었습니다')),
      );
    } catch (err) {
      print('회원가입 에러: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PostProfilePage(
                user: widget.user,
                signupData: _signupData,
                updateSessionLevel: _updateSessionLevel,
                onChangePage: () {
                  _updateCurrentPageIndex(1);
                },
                onSubmit: _submit),
          ),
        ],
      ),
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

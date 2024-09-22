import 'package:flutter/material.dart';
import 'package:lets_jam/models/signup_model.dart';
import 'package:lets_jam/screens/home_screen.dart';
import 'package:lets_jam/screens/signup_screen/optional_page.dart';
import 'package:lets_jam/screens/signup_screen/required_page.dart';
import 'package:lets_jam/widgets/progress_bar.dart';
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
  double progressPercent = 0.5;

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

  void _submit() {
    if (_signupData.level == null || _signupData.age == null) return;

    _saveUserToSupabase();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const HomeScreen(
              fromIndex: 2,
            )));
  }

  Future<void> _saveUserToSupabase() async {
    try {
      await Supabase.instance.client.from('users').insert({
        'email': widget.user.email,
        'nickname': _signupData.nickname,
        'sessions': _signupData.sessions.map((el) => el.name).toList(),
        'level': _signupData.level!.name,
        'age': _signupData.age!.name,
        'contact': _signupData.contact,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 36),
          child: Column(
            children: [
              ProgressBar(percent: progressPercent),
              Expanded(
                child: RequiredPage(
                  user: widget.user,
                  signupData: _signupData,
                  onChangePage: () {
                    _updateCurrentPageIndex(1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // return Stack(
    //   alignment: Alignment.bottomCenter,
    //   children: <Widget>[
    // PageView(
    //   scrollDirection: Axis.vertical,
    //   controller: _pageViewController,
    //   onPageChanged: _handlePageViewChanged,
    //   children: <Widget>[
    //     RequiredPage(
    //       user: widget.user,
    //       signupData: _signupData,
    //       onChangePage: () {
    //         _updateCurrentPageIndex(1);
    //       },
    //     ),
    //     OptionalPage(
    //         user: widget.user, signupData: _signupData, onSubmit: _submit)
    //   ],
    // ),
    //   ],
    // );
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_jam/screens/home_screen.dart';
import 'package:lets_jam/screens/signup_screen/signup_screen.dart';
import 'package:lets_jam/widgets/wide_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WelcomeScreen extends StatefulWidget {
  final User user;

  const WelcomeScreen({super.key, required this.user});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 56),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '회원가입 완료',
              style: TextStyle(color: Color(0xffFC5C2B)),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xffFC5C2B).withOpacity(0.3),
                borderRadius: BorderRadius.circular(50),
              ),
              child: SvgPicture.asset(
                'assets/icons/welcome-check.svg',
                fit: BoxFit.fitHeight,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              '환영합니다!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              '프로필을 입력하고\nJAM에서 즐겁게 합주 해 볼까요?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            WideButton(
                text: '프로필 작성하러 가기',
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => SignupScreen(user: widget.user)));
                }),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const HomeScreen(
                          fromIndex: 0,
                        )));
              },
              child: const Text(
                "다음에 작성할게요",
                style: TextStyle(
                    color: Color(0xffA0A0A0),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xffA0A0A0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:lets_jam/screens/signup_screen/signup_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
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
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ColorSeed.boldOrangeLight.color,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: SvgPicture.asset(
                  'assets/icons/welcome-check.svg',
                  fit: BoxFit.fitHeight,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '회원가입 완료!',
                style: TextStyle(fontSize: 20, color: Color(0xffFC5C2B)),
              ),
              const SizedBox(
                height: 94,
              ),
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '프로필을 작성하면',
                      style: TextStyle(
                          color: ColorSeed.boldOrangeMedium.color,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const BulletLi(
                      text: '밴드나 멤버를 구하는 글을 쓸 수 있어요',
                    ),
                    const BulletLi(
                      text: '게시글에 댓글을 달 수 있어요',
                    ),
                    const BulletLi(
                      text: '다른 프로필을 확인할 수 있어요',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      '* 프로필을 작성하지 않아도 게시글은 볼 수 있어요',
                      style: TextStyle(
                          color: ColorSeed.meticulousGrayMedium.color),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                '프로필을 입력하고 JAM을 같이 즐겨볼까요?',
                style: TextStyle(
                    fontSize: 16, color: ColorSeed.organizedBlackLight.color),
              ),
              const SizedBox(
                height: 22,
              ),
              WideButton(
                  text: '프로필 작성하고 시작하기',
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => SignupScreen(user: widget.user)));
                  }),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const DefaultNavigation(
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
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BulletLi extends StatelessWidget {
  const BulletLi({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "• ",
          style: TextStyle(color: ColorSeed.boldOrangeMedium.color),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: ColorSeed.boldOrangeMedium.color),
          ),
        ),
      ],
    );
  }
}

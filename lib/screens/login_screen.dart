import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:lets_jam/screens/welcome_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({
    super.key,
  });

  final supabase = Supabase.instance.client;
  final SessionController sessionController = Get.find<SessionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
              width: 222,
              child: Image.asset('assets/images/jam_full_logo.png')),
          const SizedBox(height: 160),
          Text(
            'JAM에서 함께할 밴드와 멤버를 만나보세요',
            style: TextStyle(
                fontSize: 16, color: ColorSeed.organizedBlackMedium.color),
          ),
          const SizedBox(
            height: 22,
          ),
          // bool isLoggedIn = sessionController.isLoggedIn.isTrue;
          // var user = sessionController.user.value;
          loginButton(
              context: context,
              text: '카카오로 시작하기',
              textColor: Colors.black,
              buttonColor: Colors.yellow,
              svgPath: 'assets/images/kakao.svg',
              width: 18,
              height: 18,
              onPressed: () async {
                await sessionController.signIn();
                /** 
                   * 이미 가입된 사용자면 DefaultNavigation으로,
                   * 신규 가입 사용자라면 WelcomeScreen으로
                   */
                // if (sessionController.isLoggedIn.isTrue && context.mounted) {
                //   Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) =>
                //               sessionController.user.value != null
                //                   ? const DefaultNavigation()
                //                   : WelcomeScreen(
                //                       user: supabase.auth.currentUser!)));
                // }
              }),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.06,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side:
                        BorderSide(color: ColorSeed.meticulousGrayLight.color)),
                onPressed: () {},
                child: Text('먼저 둘러볼게요',
                    style: TextStyle(
                        color: ColorSeed.organizedBlackMedium.color))),
          ),
          const SizedBox(
            height: 40,
          )
        ],
      )),
    );
  }
}

Widget loginButton({
  required BuildContext context,
  required String text,
  required VoidCallback onPressed,
  String? svgPath,
  int? width,
  int? height,
  Color? textColor,
  Color? buttonColor,
  BorderSide? side,
}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.8,
    height: MediaQuery.of(context).size.height * 0.06,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.transparent,
        backgroundColor: buttonColor,
        side: side,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              child: svgPath != null
                  ? SvgPicture.asset(
                      svgPath,
                      width: width?.toDouble(),
                      height: height?.toDouble(),
                    )
                  : Container()),
          const SizedBox(
            width: 10,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    ),
  );
}

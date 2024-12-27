import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_jam/screens/home_screen.dart';
import 'package:lets_jam/screens/signup_screen/signup_screen.dart';
import 'package:lets_jam/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.supabase,
  });

  final SupabaseClient supabase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          loginButton(
              context: context,
              text: '카카오 로그인',
              textColor: Colors.black,
              buttonColor: Colors.yellow,
              svgPath: 'assets/images/kakao.svg',
              width: 20,
              height: 20,
              onPressed: () async {
                try {
                  final success = await supabase.auth.signInWithOAuth(
                    OAuthProvider.kakao,
                    authScreenLaunchMode: LaunchMode.externalApplication,
                  );

                  supabase.auth.onAuthStateChange.listen((data) async {
                    final AuthChangeEvent event = data.event;
                    final user = Supabase.instance.client.auth.currentUser;

                    if (user == null) return;

                    final jamUser = await supabase
                        .from('users')
                        .select()
                        .eq('email', user.email!);

                    /** 
                     * 이미 가입된 사용자면 HomeScreen으로,
                     * 신규 가입 사용자라면 WelcomeScreen으로
                     */
                    if (event == AuthChangeEvent.signedIn) {
                      /** NOTE: mounted 아닌 상태도 있나? */
                      if (context.mounted) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => jamUser.isEmpty
                                    ? WelcomeScreen(user: user)
                                    : WelcomeScreen(user: user)));
                      }
                    }
                  });
                } on PlatformException catch (err) {
                  print('에러: $err');
                }
              })
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
        elevation: 2,
        backgroundColor: buttonColor,
        side: side,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Container(
              child: svgPath != null
                  ? SvgPicture.asset(
                      svgPath,
                      width: width?.toDouble(),
                      height: height?.toDouble(),
                    )
                  : Container()),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center, // 텍스트 가운데 정렬
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    ),
  );
}

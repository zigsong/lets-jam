import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lets_jam/models/user_model.dart';
import 'package:lets_jam/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionController extends GetxController {
  final supabase = Supabase.instance.client;

  /// 쨈 사용자
  var user = Rx<UserModel?>(null);

  /// supabase auth 로그인 여부
  var isLoggedIn = false.obs;

  /// 쨈 프로필 등록 여부
  var hasRegisteredProfile = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await _loadUser();

    /** NOTE: 회원가입 화면 확인용 */
    everAll([isLoggedIn, user], (_) {
      if (isLoggedIn.value && user.value != null) {
        // 원하는 곳에서 navigation 가능
        Get.to(WelcomeScreen(user: supabase.auth.currentUser!));
      }
    });
  }

  Future<void> _loadUser() async {
    try {
      final session = supabase.auth.currentSession;
      if (session == null) return;

      final sbUser = session.user;
      final data =
          await supabase.from('users').select().eq('email', sbUser.email!);

      if (data.isNotEmpty) {
        user.value = UserModel.fromJson(data[0]);
        isLoggedIn.value = true;
      }

      /** TODO: 로컬 저장 */
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('user', jsonEncode(newUser.toJson()));
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> signIn() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.kakao,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      supabase.auth.onAuthStateChange.listen((data) async {
        final AuthChangeEvent event = data.event;
        final sbUser = Supabase.instance.client.auth.currentUser;

        if (sbUser == null) return;

        if (event == AuthChangeEvent.signedIn) {
          isLoggedIn.value = true;

          final jamUser =
              await supabase.from('users').select().eq('email', sbUser.email!);

          if (jamUser.isNotEmpty) {
            user.value = UserModel.fromJson(jamUser[0]);
          }
        }
      });
    } on PlatformException catch (err) {
      print('로그인 에러: $err');
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();

      user.value = null;
      isLoggedIn.value = false;

      /** TODO: 로컬 저장 */
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.remove('user');
    } catch (e) {
      print("Error clearing user: $e");
    }
  }
}

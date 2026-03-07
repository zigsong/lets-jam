import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lets_jam/models/profile_model.dart';
import 'package:lets_jam/screens/terms_agreement_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionController extends GetxController {
  final supabase = Supabase.instance.client;

  /// 쨈 사용자
  var user = Rx<ProfileModel?>(null);

  /// supabase auth 로그인 여부
  var isLoggedIn = false.obs;

  /// 쨈 프로필 등록 여부
  var hasProfile = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await loadUser();
    _listenAuthState();
  }

  void _listenAuthState() {
    supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final sbUser = data.session?.user;

      if (event == AuthChangeEvent.signedIn && sbUser != null) {
        isLoggedIn.value = true;

        try {
          final jamUser =
              await supabase.from('profiles').select().eq('id', sbUser.id);

          if (jamUser.isNotEmpty) {
            user.value = ProfileModel.fromJson(jamUser[0]);
            user.refresh();
            hasProfile.value = true;
          } else {
            Get.to(() => TermsAgreementScreen(user: sbUser));
          }
        } catch (e) {
          print("프로필 조회 에러: $e");
        }
      }
    });
  }

  Future<void> loadUser() async {
    try {
      final session = supabase.auth.currentSession;
      if (session == null) return;

      final sessionUser = session.user;
      final data =
          await supabase.from('profiles').select().eq('id', sessionUser.id);

      isLoggedIn.value = true;

      if (data.isNotEmpty) {
        user.value = ProfileModel.fromJson(data[0]);
        user.refresh();
        hasProfile.value = true;
      } else {
        user.value = null;
        hasProfile.value = false;
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
        redirectTo: 'io.supabase.letsjam://login-callback',
      );
    } on PlatformException catch (err) {
      print('로그인 에러: $err');
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();

      user.value = null;
      isLoggedIn.value = false;
      hasProfile.value = false;

      /** TODO: 로컬 저장 */
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.remove('user');
    } catch (e) {
      print("Error clearing user: $e");
    }
  }
}

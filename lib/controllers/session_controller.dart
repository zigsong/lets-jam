import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lets_jam/models/profile_model.dart';
import 'package:lets_jam/screens/terms_agreement_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
            final consents = await supabase
                .from('user_consents')
                .select()
                .eq('user_id', sbUser.id);
            if (consents.isEmpty) {
              Get.to(() => TermsAgreementScreen(user: sbUser));
            }
            // 동의 기록 있으면 TermsAgreementScreen 스킵, 홈으로
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

  Future<void> _signInWithOAuth(OAuthProvider provider) async {
    try {
      await supabase.auth.signInWithOAuth(
        provider,
        authScreenLaunchMode: LaunchMode.externalApplication,
        redirectTo: 'io.supabase.letsjam://login-callback',
      );
    } on PlatformException catch (err) {
      print('로그인 에러: $err');
    }
  }

  Future<void> signInWithKakao() => _signInWithOAuth(OAuthProvider.kakao);

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
        nonce: rawNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        print('Apple 로그인 에러: $e');
      }
    } catch (e) {
      print('Apple 로그인 에러: $e');
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signInWithEmail(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
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

  Future<void> deleteAccount() async {
    final currentUser = user.value;

    // 1. 스토리지 이미지 삭제 (프로필이 있을 때만)
    if (currentUser != null) {
      try {
        final imagePaths = <String>[];

        if (currentUser.profileImage != null) {
          final uri = Uri.parse(currentUser.profileImage!);
          final pathSegments = uri.pathSegments;
          final storageIdx = pathSegments.indexOf('images');
          if (storageIdx != -1 && storageIdx + 1 < pathSegments.length) {
            imagePaths.add(pathSegments.sublist(storageIdx + 1).join('/'));
          }
        }

        for (final imageUrl in currentUser.backgroundImages ?? []) {
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          final storageIdx = pathSegments.indexOf('images');
          if (storageIdx != -1 && storageIdx + 1 < pathSegments.length) {
            imagePaths.add(pathSegments.sublist(storageIdx + 1).join('/'));
          }
        }

        final posts = await supabase
            .from('posts')
            .select('images')
            .eq('user_id', currentUser.id);
        for (final post in posts) {
          for (final imageUrl in (post['images'] as List<dynamic>? ?? [])) {
            final uri = Uri.parse(imageUrl as String);
            final pathSegments = uri.pathSegments;
            final storageIdx = pathSegments.indexOf('images');
            if (storageIdx != -1 && storageIdx + 1 < pathSegments.length) {
              imagePaths.add(pathSegments.sublist(storageIdx + 1).join('/'));
            }
          }
        }

        if (imagePaths.isNotEmpty) {
          await supabase.storage.from('images').remove(imagePaths);
        }
      } catch (e) {
        print("스토리지 삭제 에러 (무시하고 계속): $e");
      }
    }

    // 2. auth user 삭제 (DB cascade로 profiles, posts 자동 삭제)
    await supabase.rpc('delete_user');

    // 3. 로컬 상태 초기화
    user.value = null;
    isLoggedIn.value = false;
    hasProfile.value = false;
  }
}

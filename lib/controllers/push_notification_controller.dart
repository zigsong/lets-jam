import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// FCM 푸쉬 알림 토큰을 관리한다.
/// - 앱 시작 시 알림 권한 요청
/// - FCM 토큰을 발급받아 로그인한 유저의 기기로 Supabase(user_devices)에 저장
/// - 토큰 갱신/로그인 변화에 맞춰 재저장, 로그아웃 시 삭제
///
/// 수신 메시지 처리(포그라운드 배너, 탭 딥링크)는 Phase 4에서 추가한다.
class PushNotificationController extends GetxController {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final supabase = Supabase.instance.client;
  final SessionController _session = Get.find<SessionController>();

  @override
  void onInit() {
    super.onInit();
    _setup();
    // 로그인 상태가 true로 바뀌면 토큰을 저장한다.
    ever(_session.isLoggedIn, (bool loggedIn) {
      if (loggedIn) registerToken();
    });
  }

  Future<void> _setup() async {
    try {
      // iOS 알림 권한 요청 (시스템 팝업)
      final settings = await _messaging.requestPermission();
      debugPrint('알림 권한 상태: ${settings.authorizationStatus}');

      // 앱이 포그라운드일 때도 배너/소리로 알림을 표시한다.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 토큰이 갱신되면 다시 저장한다.
      _messaging.onTokenRefresh.listen(_saveToken);

      // 이미 로그인돼 있으면 즉시 토큰을 저장한다.
      if (_session.isLoggedIn.value) {
        await registerToken();
      }
    } catch (e) {
      debugPrint('푸쉬 알림 초기화 에러: $e');
    }
  }

  /// 현재 FCM 토큰을 발급받아 저장한다.
  Future<void> registerToken() async {
    try {
      // APNs 토큰 먼저 확인 (시뮬레이터/미설정 시 null)
      final apnsToken = await _messaging.getAPNSToken();
      debugPrint('APNs 토큰: ${apnsToken ?? "null (시뮬레이터면 정상)"}');

      final token = await _messaging.getToken();
      debugPrint('FCM 토큰: ${token ?? "null"}');

      if (token != null) {
        await _saveToken(token);
        debugPrint('FCM 토큰 저장 시도 완료 (user: ${supabase.auth.currentUser?.id})');
      }
    } catch (e) {
      debugPrint('FCM 토큰 등록 에러: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await supabase.from('user_devices').upsert(
        {
          'user_id': userId,
          'fcm_token': token,
          'platform': 'ios',
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'fcm_token',
      );
    } catch (e) {
      debugPrint('FCM 토큰 저장 에러: $e');
    }
  }

  /// 로그아웃 직전에 호출한다. (auth.signOut 이후에는 RLS로 삭제가 막힌다)
  Future<void> removeToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await supabase.from('user_devices').delete().eq('fcm_token', token);
    } catch (e) {
      debugPrint('FCM 토큰 삭제 에러: $e');
    }
  }
}

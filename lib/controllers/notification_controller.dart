import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationController extends GetxController
    with WidgetsBindingObserver {
  final supabase = Supabase.instance.client;
  final SessionController sessionController = Get.find<SessionController>();

  /// 안 읽은 알림 목록 (읽으면 목록에서 제거된다)
  final notifications = <NotificationModel>[].obs;

  /// [개발자 테스트 전용] 댓글 알림 기능 on/off.
  /// 기본값 false — dev 테스터가 개발자 테스트 화면에서 켜야 동작한다.
  final enabled = false.obs;

  bool get hasUnread => notifications.isNotEmpty;
  int get unreadCount => notifications.length;

  /// 댓글 알림 기능을 켜고 끈다. 켜면 즉시 조회, 끄면 목록을 비운다.
  void setEnabled(bool value) {
    enabled.value = value;
    if (value) {
      fetchNotifications();
    } else {
      notifications.clear();
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // 로그인/프로필 상태가 바뀔 때마다 다시 조회한다.
    ever(sessionController.user, (_) => fetchNotifications());
    fetchNotifications();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 포그라운드로 돌아오면 새 알림을 반영한다.
    if (state == AppLifecycleState.resumed) {
      fetchNotifications();
    }
  }

  Future<void> fetchNotifications() async {
    if (!enabled.value) {
      notifications.clear();
      return;
    }

    final userId = sessionController.user.value?.id;
    if (userId == null) {
      notifications.clear();
      return;
    }

    try {
      final rows = await supabase
          .from('notifications')
          .select('*, posts(title)')
          .eq('recipient_id', userId)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      notifications.value = (rows as List)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('알림 조회 에러: $e');
    }
  }

  /// 알림을 읽음 처리하고 목록에서 제거한다.
  Future<void> markAsRead(NotificationModel notification) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true}).eq('id', notification.id);
      notifications.removeWhere((e) => e.id == notification.id);
    } catch (e) {
      debugPrint('알림 읽음 처리 에러: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/notification_controller.dart';
import 'package:lets_jam/screens/alarm_screen.dart';

/// 안 읽은 알림 여부에 따라 활성/기본 벨 아이콘을 보여주는 공용 위젯.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            settings: const RouteSettings(name: 'AlarmScreen'),
            builder: (context) => const AlarmScreen(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Obx(
            () => Image.asset(
              controller.hasUnread
                  ? 'assets/icons/bell_active.png'
                  : 'assets/icons/bell_orange.png',
            ),
          ),
        ),
      ),
    );
  }
}

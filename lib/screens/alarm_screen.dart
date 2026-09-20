import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lets_jam/controllers/notification_controller.dart';
import 'package:lets_jam/models/notification_model.dart';
import 'package:lets_jam/screens/post_detail_screen/post_detail_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final NotificationController controller = Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 최신 알림을 다시 불러온다.
    controller.fetchNotifications();
  }

  void _onTapNotification(NotificationModel notification) {
    controller.markAsRead(notification);

    final postId = notification.postId;
    if (postId == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'PostDetailScreen'),
        builder: (context) => PostDetailScreen(
          postId: postId,
          userId: notification.recipientId,
        ),
      ),
    );
  }

  String _buildMessage(NotificationModel notification) {
    final title = notification.postTitle ?? '내';
    return '[$title] 게시글에 새 댓글이 달렸어요';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ColorSeed.boldOrangeMedium.color),
        title: Text(
          '알림',
          style:
              TextStyle(fontSize: 18, color: ColorSeed.boldOrangeMedium.color),
        ),
      ),
      body: Obx(() {
        final notifications = controller.notifications;

        if (notifications.isEmpty) {
          return Center(
            child: Text(
              '새로운 알림이 없어요',
              style: TextStyle(
                fontSize: 15,
                color: ColorSeed.meticulousGrayMedium.color,
              ),
            ),
          );
        }

        return ListView.separated(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return ListTile(
              title: Text(_buildMessage(notification)),
              onTap: () => _onTapNotification(notification),
            );
          },
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: ColorSeed.meticulousGrayLight.color,
              thickness: 1,
              height: 1,
            ),
          ),
        );
      }),
    );
  }
}

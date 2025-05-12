import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/screens/login_screen.dart';
import 'package:lets_jam/screens/my_info_screen.dart';
import 'package:lets_jam/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SessionController sessionController = Get.find<SessionController>();
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = sessionController.user.value;
      return (sessionController.isLoggedIn.isTrue && user != null
          ? MyInfoScreen(user: user)
          /** NOTE: WelcomeScreen 확인용 임시 */
          // ? WelcomeScreen(user: supabase.auth.currentUser!)
          : LoginScreen());
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/user_model.dart';
import 'package:lets_jam/screens/default_navigation.dart';

class MyInfoScreen extends StatefulWidget {
  final UserModel user;

  const MyInfoScreen({super.key, required this.user});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  final SessionController sessionController = Get.find<SessionController>();

  TextStyle textStyle = const TextStyle(color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              await sessionController.signOut();

              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const DefaultNavigation(
                        fromIndex: 2,
                      )));
            },
            child: const Text('로그아웃(임시)')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lets_jam/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyInfoScreen extends StatefulWidget {
  final UserModel user;

  const MyInfoScreen({super.key, required this.user});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    print('유저 email: ${widget.user.email}');

    return Center(
      child: Column(
        children: [
          Text(widget.user.email),
          Text(widget.user.nickname),
        ],
      ),
    );
  }
}

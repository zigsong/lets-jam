import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lets_jam/models/user_model.dart';
import 'package:lets_jam/screens/login_screen.dart';
import 'package:lets_jam/screens/my_info_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoggedIn = false;
  late dynamic _user;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    final user = supabase.auth.currentUser;
    if (user == null || user.email == null) {
      setState(() {
        _isLoggedIn = false;
      });
      return; // 유저가 없으면 더 이상 진행하지 않음
    }

    final data = await supabase.from('users').select().eq('email', user.email!);

    if (data.length == 1) {
      setState(() {
        _user = UserModel.fromJson(data[0]);
        _isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn
        ? MyInfoScreen(user: _user)
        : LoginScreen(supabase: supabase);
  }
}

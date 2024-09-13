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
    if (user == null || user.email == null) return;

    final data = await supabase.from('users').select().eq('email', user.email!);

    /** TODO: 이미 가입된 사용자 이메일일 경우 알럿 */
    if (data.isNotEmpty) {
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

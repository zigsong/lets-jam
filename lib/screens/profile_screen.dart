import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = supabase.auth.currentSession != null;

    // return isLoggedIn ? const MyInfoScreen() : LoginScreen(supabase: supabase);
    return LoginScreen(supabase: supabase);
  }
}

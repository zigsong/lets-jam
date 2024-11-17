import 'package:supabase_flutter/supabase_flutter.dart';

Future<dynamic> getUser() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) return;

  final jamUserData =
      await supabase.from('users').select().eq('email', user.email!).single();

  return jamUserData;
}

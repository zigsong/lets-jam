import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  final User user;

  const SignupScreen({super.key, required this.user});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String sessionInfo = '';

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // Supabase에 정보 저장 로직
      _saveUserToSupabase();
    }
  }

  Future<void> _saveUserToSupabase() async {
    try {
      final response = await Supabase.instance.client.from('users').insert({
        'email': widget.user.email,
        'session': sessionInfo,
      });
    } catch (err) {
      print('회원가입 에러: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'JAM 회원가입',
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '세션 입력'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '세션을 입력하세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  sessionInfo = value ?? '';
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

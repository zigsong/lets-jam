import 'package:flutter/material.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/widgets/tag_checkbox.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  final User user;

  const SignupScreen({super.key, required this.user});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  List<SessionEnum> sessionInfo = [];
  String nickname = '';

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // Supabase에 정보 저장 로직
      _saveUserToSupabase();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입이 완료되었습니다')),
      );
    }
  }

  Future<void> _saveUserToSupabase() async {
    try {
      final response = await Supabase.instance.client.from('users').insert({
        'email': widget.user.email,
        'nickname': nickname,
        'sessions': sessionInfo.map((el) => el.name).toList(),
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
                decoration: const InputDecoration(labelText: '닉네임'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력하세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  nickname = value ?? '';
                },
              ),
              const SizedBox(
                height: 16,
              ),
              Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '세션',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SessionCheckbox(
                    onChange: (session) {
                      if (sessionInfo.contains(session)) {
                        sessionInfo.remove(session);
                      } else {
                        sessionInfo.add(session);
                      }
                    },
                  ),
                ],
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

class SessionCheckbox extends StatefulWidget {
  final Function(SessionEnum session) onChange;

  const SessionCheckbox({super.key, required this.onChange});

  @override
  State<SessionCheckbox> createState() => _SessionCheckboxState();
}

class _SessionCheckboxState extends State<SessionCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
        children: SessionEnum.values
            .map((session) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TagCheckbox(
                    value: session,
                    label: sessionMap[session] ?? '',
                    onChange: (isChecked) {
                      widget.onChange(session);
                    },
                  ),
                ))
            .toList());
  }
}

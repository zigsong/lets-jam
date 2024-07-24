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
  String _additionalInfo = '';

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // Supabase에 정보 저장 로직
      _saveUserToSupabase();
    }
  }

  Future<void> _saveUserToSupabase() async {
    // final response = await Supabase.instance.client.from('users').insert({
    //   'id': widget.user.id,
    //   'email': widget.user.kakaoAccount?.email,
    //   'additional_info': _additionalInfo,
    // }).execute();

    // if (response.error != null) {
    //   print('Error saving to Supabase: ${response.error?.message}');
    // } else {
    //   print('User saved to Supabase');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Additional Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Additional Info'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '추가 정보를 입력하세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  _additionalInfo = value ?? '';
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/custom_form.dart';
import 'package:lets_jam/widgets/session_selector.dart';
import 'package:lets_jam/widgets/text_input.dart';
import 'package:lets_jam/widgets/wide_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ProfileRequiredEnum { nickname, sessions }

class ProfileUploadScreen extends StatefulWidget {
  const ProfileUploadScreen({super.key});

  @override
  State<ProfileUploadScreen> createState() => _ProfileUploadScreenState();
}

class _ProfileUploadScreenState extends State<ProfileUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<ProfileRequiredEnum, bool> _validators = {};

  String _nickname = '';
  final List<SessionEnum> _sessions = [];
  String? _contact;
  String? _bio;

  bool _validate() {
    if (_nickname.isEmpty) {
      setState(() {
        _validators[ProfileRequiredEnum.nickname] = false;
      });
    }
    if (_sessions.isEmpty) {
      setState(() {
        _validators[ProfileRequiredEnum.sessions] = false;
      });
    }
    return _validators.values.every((value) => value == true);
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _validate()) {
      _formKey.currentState!.save();
      _saveProfileToSupabase();
    }
  }

  Future<void> _saveProfileToSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('profiles').insert({
        'email': user.email,
        'nickname': _nickname,
        'sessions': _sessions.map((el) => el.name).toList(),
        'contact': _contact,
        'bio': _bio,
        // TODO: 사진도 넣기
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필을 등록했어요')),
      );

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const DefaultNavigation(fromIndex: 2),
      ));
    } catch (err) {
      print('프로필 등록 에러: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: ColorSeed.boldOrangeStrong.color, size: 20),
        shape: Border(
            bottom:
                BorderSide(color: ColorSeed.boldOrangeStrong.color, width: 1)),
        title: Text(
          '프로필 작성',
          style: TextStyle(
              fontSize: 16,
              color: ColorSeed.boldOrangeStrong.color,
              fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xffF2F2F2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextInput(
                    label: '닉네임',
                    isRequired: true,
                    placeholder: '닉네임을 입력하세요',
                    onChanged: (value) {
                      _validators[ProfileRequiredEnum.nickname] = true;
                      _nickname = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '닉네임을 입력하세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomForm(
                        label: '세션',
                        isRequired: true,
                        subTitle: '다룰 수 있는 세션을 모두 선택해주세요!'),
                    if (_validators[ProfileRequiredEnum.sessions] == false)
                      const Text(
                        '세션을 선택해주세요',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
                SessionSelector(
                  selectedSessions: _sessions,
                  onChange: (session) {
                    setState(() {
                      if (_sessions.contains(session)) {
                        _sessions.remove(session);
                      } else {
                        _sessions.add(session);
                      }
                      _validators[ProfileRequiredEnum.sessions] = true;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextInput(
                    label: '연락처',
                    placeholder: '연락처를 입력하세요',
                    onChanged: (value) {
                      _contact = value;
                    },
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(height: 16),
                TextInput(
                  label: '자기소개',
                  onChanged: (value) {
                    _bio = value;
                  },
                  keyboardType: TextInputType.multiline,
                  height: 96,
                ),
                const SizedBox(height: 30),
                WideButton(
                  // TODO: 처음 온 건지, 나중에 온 건지에 따라 cta text 구분하기
                  text: 'JAM 시작하기!',
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

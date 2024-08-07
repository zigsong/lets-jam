import 'package:flutter/material.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/widgets/tag_checkbox.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequiredPage extends StatefulWidget {
  final User user;
  final Function() onChangePage;

  const RequiredPage(
      {super.key, required this.user, required this.onChangePage});

  @override
  State<RequiredPage> createState() => _RequiredPageState();
}

class _RequiredPageState extends State<RequiredPage> {
  final _formKey = GlobalKey<FormState>();

  late String _nickname = '';
  late final List<SessionEnum> _sessionInfo = [];
  late LevelEnum _level;
  late AgeEnum _age;

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // supabase에 정보 저장
      /** TODO: 상태관리를 추가할 시점 */
      // _saveUserToSupabase();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('회원가입이 완료되었습니다')),
      // );

      // optional 정보 입력 페이지로 이동
      widget.onChangePage();
    }
  }

  Future<void> _saveUserToSupabase() async {
    try {
      final response = await Supabase.instance.client.from('users').insert({
        'email': widget.user.email,
        'nickname': _nickname,
        'sessions': _sessionInfo.map((el) => el.name).toList(),
        'level': _level.name,
        'age': _age.name,
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
        '필수정보 입력',
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
                  _nickname = value ?? '';
                },
              ),
              const SizedBox(
                height: 16,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '세션',
                  textAlign: TextAlign.left,
                ),
              ),
              SessionCheckbox(
                onChange: (session) {
                  if (_sessionInfo.contains(session)) {
                    _sessionInfo.remove(session);
                  } else {
                    _sessionInfo.add(session);
                  }
                },
              ),
              const SizedBox(
                height: 16,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '레벨',
                  textAlign: TextAlign.left,
                ),
              ),
              LevelOption(
                onSelect: (level) {
                  _level = level;
                },
              ),
              const SizedBox(
                height: 16,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '연령대',
                  textAlign: TextAlign.left,
                ),
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: AgeDropdown(
                      onSelect: (age) {
                        _age = age;
                      },
                    ),
                  )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('계속'),
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

class LevelOption extends StatefulWidget {
  final Function(LevelEnum level) onSelect;

  const LevelOption({super.key, required this.onSelect});

  @override
  State<LevelOption> createState() => _LevelOptionState();
}

class _LevelOptionState extends State<LevelOption> {
  LevelEnum _level = LevelEnum.newbie;

  @override
  Widget build(BuildContext context) {
    return Wrap(
        children: LevelEnum.values
            .map((level) => RadioListTile(
                  title: Text(levelMap[level] ?? ''),
                  value: level,
                  groupValue: _level,
                  activeColor: Colors.amber.shade700,
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (LevelEnum? value) {
                    widget.onSelect(value ?? LevelEnum.newbie);
                    setState(() {
                      _level = value!;
                    });
                  },
                ))
            .toList());
  }
}

class AgeDropdown extends StatefulWidget {
  final Function(AgeEnum age) onSelect;

  const AgeDropdown({super.key, required this.onSelect});

  @override
  State<AgeDropdown> createState() => _AgeDropdownState();
}

class _AgeDropdownState extends State<AgeDropdown> {
  AgeEnum _age = AgeEnum.lt20;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<AgeEnum>(
        value: _age,
        items: AgeEnum.values
            .map((age) =>
                DropdownMenuItem(value: age, child: Text(ageMap[age]!)))
            .toList(),
        onChanged: (AgeEnum? value) {
          widget.onSelect(value!);
          setState(() {
            _age = value;
          });
        });
  }
}

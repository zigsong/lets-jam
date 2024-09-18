import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/models/signup_model.dart';
import 'package:lets_jam/widgets/progress_bar.dart';
import 'package:lets_jam/widgets/tag_checkbox.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequiredPage extends StatefulWidget {
  final User user;
  final Function() onChangePage;
  final SignupModel signupData;

  const RequiredPage(
      {super.key,
      required this.user,
      required this.onChangePage,
      required this.signupData});

  @override
  State<RequiredPage> createState() => _RequiredPageState();
}

class _RequiredPageState extends State<RequiredPage> {
  final _formKey = GlobalKey<FormState>();
  double percent = 0.5;

  void _changePage() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      widget.onChangePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 36),
          child: Column(
            children: [
              ProgressBar(percent: percent),
              Center(
                  child: ProfileImagePicker(
                onSelect: (file) {
                  setState(() {
                    widget.signupData.profileImage = file;
                  });
                },
                profileImage: widget.signupData.profileImage,
              )),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      '회원가입에 관한 서브 텍스트 회원가입에 관한 서브 텍스트 회원가입에 관한 서브 텍스트',
                      style: TextStyle(fontSize: 12),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: '닉네임'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '닉네임을 입력하세요';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        widget.signupData.nickname = value ?? '';
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
                        if (widget.signupData.sessions.contains(session)) {
                          widget.signupData.sessions.remove(session);
                        } else {
                          widget.signupData.sessions.add(session);
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
                        widget.signupData.level = level;
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
                              widget.signupData.age = age;
                            },
                          ),
                        )),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _changePage,
                      child: const Text('계속'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileImagePicker extends StatefulWidget {
  final Function(XFile file) onSelect;
  final XFile? profileImage;

  const ProfileImagePicker(
      {super.key, required this.onSelect, this.profileImage});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final ImagePicker picker = ImagePicker();

  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      widget.onSelect(XFile(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: GestureDetector(
        child: Align(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                width: 138,
                height: 138,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(100)),
                clipBehavior: Clip.antiAlias, //
                child: widget.profileImage != null
                    ? Image.file(
                        File(widget.profileImage!.path),
                        fit: BoxFit.cover,
                      )
                    : Image.asset('assets/images/avatar.png'),
              ),
              Positioned(
                right: 0,
                top: 20,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      color: const Color(0xffBFFFAF),
                      borderRadius: BorderRadius.circular(100)),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/edit.png',
                      width: 10,
                      height: 10,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () {
          getImage(ImageSource.gallery);
        },
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

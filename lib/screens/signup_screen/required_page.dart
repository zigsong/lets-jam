import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/models/signup_model.dart';
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
    return SingleChildScrollView(
      child: Column(
        children: [
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
                  height: 16,
                ),
                const Text(
                  '회원가입에 관한 서브 텍스트 회원가입에 관한 서브 텍스트 회원가입에 관한 서브 텍스트',
                  style: TextStyle(fontSize: 12),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SignupInput(
                    label: '닉네임',
                    onSave: (value) {
                      widget.signupData.nickname = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '닉네임을 입력하세요';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SignupInput(
                    label: '연락처',
                    onSave: (value) {
                      widget.signupData.contact = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '연락처를 입력하세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SignupDropdown<AgeEnum>(
                  label: '나이',
                  placeholder: '나이를 선택해 주세요',
                  currentValue: widget.signupData.age,
                  options: AgeEnum.values,
                  optionValues: ageMap,
                  onSelect: (AgeEnum age) {
                    setState(() {
                      widget.signupData.age = age;
                    });
                  },
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
    );
  }
}

class SignupInput extends StatelessWidget {
  const SignupInput(
      {super.key, required this.label, required this.onSave, this.validator});

  final String label;
  final void Function(String?) onSave;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: SizedBox(
            height: 44,
            child: TextFormField(
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xffAED3FF), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xffAED3FF), width: 2),
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              cursorColor: const Color(0xffAED3FF),
              validator: validator,
              onSaved: onSave,
            ),
          ),
        ),
      ],
    );
  }
}

class SignupDropdown<T> extends StatefulWidget {
  const SignupDropdown(
      {super.key,
      required this.label,
      required this.placeholder,
      required this.currentValue,
      required this.options,
      required this.optionValues,
      required this.onSelect});

  final String label;
  final String placeholder;
  final T? currentValue;
  final List<T> options;
  final Map<T, String> optionValues;
  final Function(T value) onSelect;

  @override
  State<SignupDropdown<T>> createState() => _SignupDropdownState<T>();
}

class _SignupDropdownState<T> extends State<SignupDropdown<T>> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _targetKey = GlobalKey();

  void _showDropdown() {
    final targetContext = _targetKey.currentContext;
    final renderBox = targetContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: renderBox.size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 24),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: const Color(0xffAED3FF)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.options
                  .asMap()
                  .entries
                  .map((entry) => Material(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          splashColor: const Color(0xffAED3FF),
                          highlightColor: const Color(0xffAED3FF),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              width: double.infinity,
                              height: 44,
                              decoration: BoxDecoration(
                                  border: entry.key > 0
                                      ? const Border(
                                          top: BorderSide(
                                              width: 2,
                                              color: Color(0xffAED3FF)),
                                        )
                                      : null,
                                  borderRadius: entry.key == 0
                                      ? BorderRadius.circular(12)
                                      : null),
                              child: Text(widget.optionValues[entry.value]!)),
                          onTap: () {
                            widget.onSelect(entry.value);
                            _hideDropdown();
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    String displayValue;
    if (widget.currentValue is Enum) {
      displayValue = widget.optionValues[(widget.currentValue as Enum)]!;
    } else if (widget.currentValue is String) {
      displayValue = widget.currentValue as String; // 그대로 사용
    } else {
      displayValue = widget.placeholder;
    }

    return Stack(
      children: [
        Positioned(
            child: Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        GestureDetector(
          onTap: _showDropdown,
          child: CompositedTransformTarget(
            link: _layerLink,
            child: Padding(
                padding: const EdgeInsets.only(top: 24),
                key: _targetKey,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    border:
                        Border.all(width: 2, color: const Color(0xffAED3FF)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(displayValue),
                      Image.asset(
                        'assets/icons/arrow_down.png',
                        width: 12,
                        height: 12,
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ],
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
                clipBehavior: Clip.antiAlias,
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

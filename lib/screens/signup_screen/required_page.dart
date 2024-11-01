import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/models/signup_model.dart';
import 'package:lets_jam/widgets/text_input.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequiredPage extends StatefulWidget {
  final User user;
  final Function() onChangePage;
  final SignupModel signupData;

  /// TODO: 상태관리로 수정하기
  final Function(SessionEnum key, LevelEnum value) updateSessionLevel;
  final Function() onSubmit;

  const RequiredPage(
      {super.key,
      required this.user,
      required this.onChangePage,
      required this.signupData,
      required this.updateSessionLevel,
      required this.onSubmit});

  @override
  State<RequiredPage> createState() => _RequiredPageState();
}

class _RequiredPageState extends State<RequiredPage> {
  final _formKey = GlobalKey<FormState>();
  Map<SignupRequiredEnum, bool> valiators = {};
  double percent = 0.5;

  void _changePage() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      widget.onChangePage();
    }
  }

  bool _validate() {
    if (widget.signupData.nickname.isEmpty) {
      setState(() {
        valiators[SignupRequiredEnum.nickname] = false;
      });
    }
    if (widget.signupData.sessions.isEmpty) {
      // NOTE: setState 안하면 SessionCheckbox validation이 안된다
      setState(() {
        valiators[SignupRequiredEnum.sessions] = false;
      });
    }
    return valiators.values.every((value) => value == true);
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _validate()) {
      _formKey.currentState!.save();

      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            'JAM 가입하기',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  '회원가입에 관한 서브 텍스트 회원가입에 관한 서브 텍스트 회원가입에 관한 서브 텍스트',
                  style: TextStyle(fontSize: 12),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextInput(
                    label: '닉네임',
                    placeholder: '닉네임을 입력하세요',
                    onChange: (value) {
                      valiators[SignupRequiredEnum.nickname] = true;
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
                  child: TextInput(
                    label: '연락처',
                    placeholder: '연락처를 입력하세요',
                    onChange: (value) {
                      widget.signupData.contact = value ?? '';
                    },
                    keyboardType: TextInputType.phone,
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
                const SizedBox(
                  height: 16,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SessionSelector(
                        label: '세션', subtext: '다룰 수 있는 세션을 모두 선택해주세요!'),
                    if (valiators[SignupRequiredEnum.sessions] == false)
                      const Text(
                        '세션을 선택해주세요',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SessionCheckbox(
                    selectedList: widget.signupData.sessions,
                    onChange: (session) {
                      setState(() {
                        if (widget.signupData.sessions.contains(session)) {
                          widget.signupData.sessions.remove(session);
                          valiators[SignupRequiredEnum.sessions] = true;
                        } else {
                          widget.signupData.sessions.add(session);
                          valiators[SignupRequiredEnum.sessions] = true;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: widget.signupData.sessions.map((session) {
                    return Column(
                      children: [
                        LevelSelector(
                          session: session,
                          onSelect: (level) {
                            setState(() {
                              widget.updateSessionLevel(session, level);
                            });
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    );
                  }).toList(),
                ),
                TextInput(
                  label: '자기소개',
                  onChange: (value) {
                    widget.signupData.bio = value;
                  },
                  keyboardType: TextInputType.multiline,
                  height: 96,
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xffBFFFAF),
                      foregroundColor: const Color(0xff1c1c1c),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'JAM 시작하기',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              color: Colors.white,
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

class SessionSelector extends StatelessWidget {
  const SessionSelector({super.key, required this.label, this.subtext});

  final String label;
  final String? subtext;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (subtext != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(subtext!, style: const TextStyle(fontSize: 12)),
              )
          ],
        )),
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
      padding: const EdgeInsets.symmetric(vertical: 20),
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
  final List<SessionEnum> selectedList;
  final Function(SessionEnum session) onChange;

  const SessionCheckbox(
      {super.key, required this.selectedList, required this.onChange});

  @override
  State<SessionCheckbox> createState() => _SessionCheckboxState();
}

class _SessionCheckboxState extends State<SessionCheckbox> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: SessionEnum.values
              .map((session) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GestureDetector(
                    child: Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color(0xffBFFFAF),
                          borderRadius: BorderRadius.circular(12),
                          border: widget.selectedList.contains(session)
                              ? Border.all(
                                  color: const Color(0xffFF60F9),
                                  width: 3,
                                )
                              : null),
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text(sessionMap[session]!)),
                    ),
                    onTap: () {
                      setState(() {
                        widget.onChange(session);
                      });
                    },
                  )))
              .toList()),
    );
  }
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

class LevelSelector extends StatefulWidget {
  final SessionEnum session;
  final Function(LevelEnum level) onSelect;

  const LevelSelector(
      {super.key, required this.session, required this.onSelect});

  @override
  State<LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<LevelSelector> {
  LevelEnum? _level;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return (Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xffBFFFAF),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${sessionMap[widget.session]} 레벨',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xff8F9098)),
              ],
            ),
          ),
        ),
        AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xffBFFFAF), width: 2),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12))),
            child: !_isExpanded && _level == null
                ? null
                : Wrap(
                    children: (!_isExpanded && _level != null
                            ? LevelEnum.values.where((level) => level == _level)
                            : LevelEnum.values)
                        .map((level) => RadioListTile(
                              title: Text(
                                sessionLevelText[widget.session]?[level] ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                              value: level,
                              groupValue: _level,
                              activeColor: const Color(0xff006FFD),
                              visualDensity: const VisualDensity(
                                vertical: VisualDensity.minimumDensity,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              controlAffinity: ListTileControlAffinity.trailing,
                              contentPadding: const EdgeInsets.only(
                                  top: 4, left: 12, right: 4, bottom: 4),
                              onChanged: (LevelEnum? value) {
                                widget.onSelect(value!);
                                setState(() {
                                  _level = value;
                                  setState(() {
                                    _isExpanded = false;
                                  });
                                });
                              },
                            ))
                        .toList())),
      ],
    ));
  }
}

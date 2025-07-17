import 'package:flutter/material.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/models/signup_model.dart';
import 'package:lets_jam/screens/signup_screen/birth_year_picker.dart';
import 'package:lets_jam/screens/signup_screen/profile_image_picker.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/custom_form.dart';
import 'package:lets_jam/widgets/session_selector.dart';
import 'package:lets_jam/widgets/text_input.dart';
import 'package:lets_jam/widgets/wide_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostProfilePage extends StatefulWidget {
  final User user;
  final Function() onChangePage;
  final SignupModel signupData;

  final Function() onSubmit;

  const PostProfilePage(
      {super.key,
      required this.user,
      required this.onChangePage,
      required this.signupData,
      required this.onSubmit});

  @override
  State<PostProfilePage> createState() => _PostProfilePageState();
}

class _PostProfilePageState extends State<PostProfilePage> {
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
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TextInput(
                        label: '닉네임',
                        isRequired: true,
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
                    BirthYearPicker(onSelect: (DateTime birthDate) {
                      setState(() {
                        // @zigsong TODO: birthDate -> age 변환 로직
                        // widget.signupData.age = age;
                      });
                    }),
                    const SizedBox(
                      height: 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomForm(
                            label: '세션',
                            isRequired: true,
                            subTitle: '다룰 수 있는 세션을 모두 선택해주세요!'),
                        if (valiators[SignupRequiredEnum.sessions] == false)
                          const Text(
                            '세션을 선택해주세요',
                            style: TextStyle(color: Colors.red),
                          )
                      ],
                    ),
                    SessionSelector(
                      selectedSessions: widget.signupData.sessions,
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
                    const SizedBox(
                      height: 16,
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
                    WideButton(
                      text: 'JAM 시작하기!',
                      onPressed: _submit,
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

// class LevelSelector extends StatefulWidget {
//   final SessionEnum session;
//   final Function(LevelEnum level) onSelect;

//   const LevelSelector(
//       {super.key, required this.session, required this.onSelect});

//   @override
//   State<LevelSelector> createState() => _LevelSelectorState();
// }

// class _LevelSelectorState extends State<LevelSelector> {
//   LevelEnum? _level;
//   bool _isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return (Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               _isExpanded = !_isExpanded;
//             });
//           },
//           child: Container(
//             height: 48,
//             padding: const EdgeInsets.all(16),
//             decoration: const BoxDecoration(
//               color: Color(0xffBFFFAF),
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12), topRight: Radius.circular(12)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '${sessionMap[widget.session]} 레벨',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Icon(
//                     _isExpanded
//                         ? Icons.keyboard_arrow_up
//                         : Icons.keyboard_arrow_down,
//                     color: const Color(0xff8F9098)),
//               ],
//             ),
//           ),
//         ),
//         AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             decoration: BoxDecoration(
//                 border: Border.all(color: const Color(0xffBFFFAF), width: 2),
//                 borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(12),
//                     bottomRight: Radius.circular(12))),
//             child: !_isExpanded && _level == null
//                 ? null
//                 : Wrap(
//                     children: (!_isExpanded && _level != null
//                             ? LevelEnum.values.where((level) => level == _level)
//                             : LevelEnum.values)
//                         .map((level) => RadioListTile(
//                               title: Text(
//                                 sessionLevelText[widget.session]?[level] ?? '',
//                               ),
//                               value: level,
//                               groupValue: _level,
//                               activeColor: const Color(0xff006FFD),
//                               visualDensity: const VisualDensity(
//                                 vertical: VisualDensity.minimumDensity,
//                               ),
//                               materialTapTargetSize:
//                                   MaterialTapTargetSize.shrinkWrap,
//                               controlAffinity: ListTileControlAffinity.trailing,
//                               contentPadding: const EdgeInsets.only(
//                                   top: 4, left: 12, right: 4, bottom: 4),
//                               onChanged: (LevelEnum? value) {
//                                 widget.onSelect(value!);
//                                 setState(() {
//                                   _level = value;
//                                   setState(() {
//                                     _isExpanded = false;
//                                   });
//                                 });
//                               },
//                             ))
//                         .toList())),
//       ],
//     ));
//   }
// }

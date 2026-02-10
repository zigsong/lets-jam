import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/models/profile_upload_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/widgets/custom_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/widgets/text_input.dart';
import 'package:lets_jam/widgets/wide_button.dart';
import 'package:lets_jam/widgets/session_selector.dart';
import 'package:lets_jam/widgets/form_error_message.dart';

class ProfileUploadScreen extends StatefulWidget {
  const ProfileUploadScreen({
    super.key,
  });

  @override
  State<ProfileUploadScreen> createState() => _ProfileUploadScreenState();
}

class _ProfileUploadScreenState extends State<ProfileUploadScreen> {
  // final ProfileModel? _profile;
  final _formKey = GlobalKey<FormState>();

  final FocusNode nickname = FocusNode();
  final FocusNode _contactFocus = FocusNode();

  final supabase = Supabase.instance.client;
  final SessionController sessionController = Get.find<SessionController>();

  late ProfileUploadModel formData;

  // validation용
  String? _nicknameErrorText;
  String? _contactErrorText;
  bool _sessionError = false;

  final _sessionKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProfileImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        formData.profileImage = pickedFile.path;
      });
    }
  }

  Future<void> _pickBackgroundImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        formData.backgroundImages = [pickedFile.path];
      });
    }
  }

  @override
  void initState() {
    super.initState();

    formData = ProfileUploadModel.init();
  }

  Future<void> _submit() async {
    setState(() {
      _nicknameErrorText = null;
      _contactErrorText = null;
      _sessionError = false;
    });

    bool hasError = false;

    /** TODO: 닉네임 중복 검사 추가 */
    if (formData.nickname.trim().isEmpty) {
      _nicknameErrorText = '닉네임을 입력해주세요';
      hasError = true;
    }
    if (formData.sessions.isEmpty) {
      _sessionError = true;
      hasError = true;
    }
    if (formData.contact.trim().isEmpty) {
      _contactErrorText = '연락처를 입력해주세요';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      if (formData.nickname.isEmpty) {
        FocusScope.of(context).requestFocus(nickname);
      } else if (formData.sessions.isEmpty &&
          _sessionKey.currentContext != null) {
        Scrollable.ensureVisible(_sessionKey.currentContext!,
            duration: const Duration(milliseconds: 300));
      } else if (formData.contact.isEmpty) {
        FocusScope.of(context).requestFocus(_contactFocus);
      }
      return;
    }

    try {
      await _createProfile();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackbar('프로필 작성을 완료했습니다'),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('프로필 저장 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(customSnackbar('저장 실패: $e'));
    }
  }

  Future<void> _createProfile() async {
    final userId = supabase.auth.currentUser!.id;

    final backgroundImageUrls = await _uploadImages(formData.backgroundImages);

    await supabase.from('profiles').insert({
      'id': userId,
      'nickname': formData.nickname,
      'sessions': formData.sessions.map((e) => e.name).toList(),
      'contact': formData.contact,
      'bio': formData.bio,
      'profile_image': formData.profileImage,
      'background_images': backgroundImageUrls,
    });
  }

  Future<List<String>> _uploadImages(List<String> paths) async {
    const bucket = 'images';
    final urls = <String>[];

    for (final image in paths) {
      if (image.startsWith('http')) {
        urls.add(image);
        continue;
      }

      final path =
          'profile_uploads/${DateTime.now().millisecondsSinceEpoch}-${image.split('/').last}';
      final res = await supabase.storage.from(bucket).upload(path, File(image));
      final filePath = res.replaceFirst('$bucket/', '');
      final url = supabase.storage.from(bucket).getPublicUrl(filePath);

      urls.add(url);
    }

    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '프로필 작성하기',
          style: TextStyle(
              fontSize: 16,
              color: ColorSeed.boldOrangeStrong.color,
              fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            IconThemeData(color: ColorSeed.boldOrangeStrong.color, size: 20),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 483,
              decoration: BoxDecoration(
                color: ColorSeed.boldOrangeLight.color,
                image: formData.backgroundImages.isNotEmpty
                    ? DecorationImage(
                        image: FileImage(File(formData.backgroundImages.first)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: SizedBox(
                          width: 102,
                          height: 102,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              formData.profileImage.isEmpty
                                  ? Image.asset(
                                      'assets/images/profile_avatar.png',
                                      width: 102,
                                      height: 102,
                                    )
                                  : ClipOval(
                                      child: Image.file(
                                        File(formData.profileImage),
                                        width: 102,
                                        height: 102,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Image.asset(
                                  'assets/icons/profile_image_edit.png',
                                  width: 32,
                                  height: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 26,
                    child: GestureDetector(
                      onTap: _pickBackgroundImage,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: ColorSeed.boldOrangeRegular.color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/white_camera.png',
                            width: 26,
                            height: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextInput(
                          label: '닉네임',
                          focusNode: nickname,
                          initialValue: formData.nickname,
                          isRequired: true,
                          errorText: _nicknameErrorText,
                          onChanged: (value) {
                            setState(() {
                              formData.nickname = value;
                              _nicknameErrorText = null;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        CustomForm(
                          key: _sessionKey,
                          label: '세션',
                          subTitle: '다룰 수 있는 세션을 모두 선택해주세요',
                          isRequired: true,
                          content: SessionSelector(
                            selectedSessions: formData.sessions,
                            onChange: (session) {
                              setState(() {
                                if (formData.sessions.contains(session)) {
                                  formData.sessions.remove(session);
                                } else {
                                  formData.sessions.add(session);
                                }
                                _sessionError = false;
                              });
                            },
                          ),
                        ),
                        if (_sessionError)
                          const FormErrorMessage(message: '1개 이상 선택해주세요'),
                        const SizedBox(
                          height: 30,
                        ),
                        CustomForm(
                          label: '연락처',
                          isRequired: true,
                          subTitle: '카카오톡 오픈채팅방 링크, SNS 계정 등 공개 가능한 연락처를 적어주세요',
                          content: TextInput(
                            focusNode: _contactFocus,
                            initialValue: formData.contact,
                            errorText: _contactErrorText,
                            onChanged: (value) {
                              setState(() {
                                formData.contact = value;
                                _contactErrorText = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        CustomForm(
                          label: '자기소개',
                          subTitle: '50자 이내로 작성해주세요',
                          content: TextInput(
                            initialValue: formData.bio,
                            onChanged: (value) {
                              formData.bio = value;
                            },
                            keyboardType: TextInputType.multiline,
                            height: 96,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        WideButton(
                          text: '작성하기',
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

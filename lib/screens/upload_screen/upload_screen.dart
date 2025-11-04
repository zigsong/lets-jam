import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/find_session_upload_model.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:lets_jam/screens/upload_screen/region_selector.dart';
import 'package:lets_jam/screens/upload_screen/hashtag_selector.dart';
import 'package:lets_jam/screens/upload_screen/upload_type_toggler.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/widgets/custom_form.dart';
import 'package:lets_jam/widgets/multiple_image_picker.dart';
import 'package:lets_jam/widgets/session_selector.dart';
import 'package:lets_jam/widgets/text_input.dart';
import 'package:lets_jam/widgets/wide_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Map<PostTypeEnum, String> postTypeTitle = {
  PostTypeEnum.findBand: '밴드',
  PostTypeEnum.findMember: '멤버',
};

// ignore: constant_identifier_names
const SUPABASE_BUCKET_NAME = 'images';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  PostTypeEnum postType = PostTypeEnum.findMember;
  final _formKey = GlobalKey<FormState>();

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contactFocus = FocusNode();

  final supabase = Supabase.instance.client;
  final SessionController sessionController = Get.find<SessionController>();

  final FindSessionUploadModel _findSessionUploadData =
      FindSessionUploadModel.init();

  String? _titleErrorText;
  String? _contactErrorText;
  bool _sessionError = false; // 세션 선택 유효성용 flag
  bool _regionError = false;

  final _sessionKey = GlobalKey();

  Future<void> _submit() async {
    setState(() {
      _titleErrorText = null;
      _contactErrorText = null;
      _sessionError = false;
      _regionError = false;
    });

    bool hasError = false;

    if (_findSessionUploadData.sessions.isEmpty) {
      setState(() => _sessionError = true);
    } else {
      setState(() => _sessionError = false);
    }
    if (_findSessionUploadData.title.isEmpty) {
      _titleErrorText = '제목을 입력해주세요';
      hasError = true;
    }
    if (_findSessionUploadData.sessions.isEmpty) {
      _sessionError = true;
      hasError = true;
    }
    if (_findSessionUploadData.contact.isEmpty) {
      _contactErrorText = '연락처를 입력해주세요';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      if (_findSessionUploadData.title.isEmpty) {
        FocusScope.of(context).requestFocus(_titleFocus);
      } else if (_findSessionUploadData.sessions.isEmpty) {
        Scrollable.ensureVisible(_sessionKey.currentContext!,
            duration: const Duration(milliseconds: 300));
      } else if (_findSessionUploadData.contact.isEmpty) {
        FocusScope.of(context).requestFocus(_contactFocus);
      }
      return;
    }
    _formKey.currentState!.save();
    await _savePostToSupabase();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DefaultNavigation()));
  }

  void _toggleUploadType() {
    if (postType == PostTypeEnum.findMember) {
      setState(() {
        postType = PostTypeEnum.findBand;
      });
    } else {
      setState(() {
        postType = PostTypeEnum.findMember;
      });
    }
  }

  Future<void> _savePostToSupabase() async {
    try {
      final user = sessionController.user.value;
      final String userId = user!.id;
      final List<String> imageUrls = [];

      for (var image in _findSessionUploadData.images) {
        final path =
            'post_uploads/${DateTime.now().millisecondsSinceEpoch}-${image.split('/').last}';

        final response = await supabase.storage
            .from(SUPABASE_BUCKET_NAME)
            .upload(path, File(image));

        final filePath = response.replaceFirst('$SUPABASE_BUCKET_NAME/', '');

        final imagePublicUrl =
            supabase.storage.from(SUPABASE_BUCKET_NAME).getPublicUrl(filePath);
        imageUrls.add(imagePublicUrl);
      }

      await supabase.from('posts').insert({
        'user_id': userId,
        'title': _findSessionUploadData.title,
        'levels': _findSessionUploadData.levels.map((el) => el.name).toList(),
        'sessions':
            _findSessionUploadData.sessions.map((el) => el.name).toList(),
        'ages': _findSessionUploadData.ages.map((el) => el.name).toList(),
        'regions':
            _findSessionUploadData.regions.map((el) => el.displayName).toList(),
        'contact': _findSessionUploadData.contact,
        'description': _findSessionUploadData.description,
        'tags': _findSessionUploadData.tags,
        'images': imageUrls,
        'post_type': postType.name,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(customSnackbar('게시글을 작성했습니다.'));
    } catch (err) {
      print('게시글 작성 에러: $err');
      ScaffoldMessenger.of(context)
          .showSnackBar(customSnackbar('업로드 실패: $err'));
    }
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _contactFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /** 
         * extendBodyBehindAppBar 대신 사용
         * - 스크롤 시에도 App Bar 뒤쪽에 색상 생기지 않도록
         * */
        forceMaterialTransparency: true,
        backgroundColor: ColorSeed.boldOrangeLight.color,
        elevation: 0,
        iconTheme:
            IconThemeData(color: ColorSeed.boldOrangeStrong.color, size: 20),
        title: Text(
          '글쓰기',
          style: TextStyle(
              fontSize: 16,
              color: ColorSeed.boldOrangeStrong.color,
              fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          child: Column(
            children: [
              UploadTypeToggler(
                  onTap: _toggleUploadType,
                  selectedIndex: postType == PostTypeEnum.findMember ? 0 : 1),
              const SizedBox(
                height: 30,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextInput(
                      label: '제목',
                      focusNode: _titleFocus,
                      isRequired: true,
                      errorText: _titleErrorText,
                      onChanged: (value) {
                        setState(() {
                          _findSessionUploadData.title = value;
                          _titleErrorText = null;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomForm(
                      label: '세션',
                      subTitle: '밴드가 원하는 멤버의 세션을 모두 선택해주세요.',
                      isRequired: true,
                      content: SessionSelector(
                        selectedSessions: _findSessionUploadData.sessions,
                        onChange: (session) {
                          setState(() {
                            if (_findSessionUploadData.sessions
                                .contains(session)) {
                              _findSessionUploadData.sessions.remove(session);
                            } else {
                              _findSessionUploadData.sessions.add(session);
                            }
                            _sessionError = false;
                          });
                        },
                      ),
                    ),
                    if (_sessionError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: 13.5,
                                  height: 13.5,
                                  child: Image.asset('assets/icons/info.png')),
                              const SizedBox(width: 7),
                              const Text(
                                '세션을 최소 1개 이상 선택해주세요',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomForm(
                      label: '지역',
                      subTitle: '합주할 수 있는 지역을 선택해 주세요 (최대 3개)',
                      content: RegionSelector(
                        selectedRegions: _findSessionUploadData.regions,
                        onChange: (region) {
                          setState(() {
                            if (_findSessionUploadData.regions
                                .contains(region)) {
                              _findSessionUploadData.regions.remove(region);
                              _regionError = false;
                            } else {
                              if (_findSessionUploadData.regions.length >= 3) {
                                _regionError = true;
                                return;
                              }
                              _regionError = false;
                              _findSessionUploadData.regions.add(region);
                            }
                          });
                        },
                      ),
                    ),
                    if (_regionError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: 13.5,
                                  height: 13.5,
                                  child: Image.asset('assets/icons/info.png')),
                              const SizedBox(width: 7),
                              const Text(
                                '지역은 최대 3개까지 선택할 수 있어요',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomForm(
                      label: '해시태그',
                      subTitle: '자유롭게 작성해주세요 (최대 5개) #대학생밴드 #데이식스 #메탈',
                      content: HashTagSelector(
                        selectedTags: _findSessionUploadData.tags,
                        onSelect: (tag) {
                          if (_findSessionUploadData.tags.contains(tag)) {
                            _findSessionUploadData.tags.remove(tag);
                          } else {
                            if (_findSessionUploadData.tags.length >= 5) return;
                            _findSessionUploadData.tags.add(tag);
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomForm(
                      label: '사진',
                      subTitle: '밴드를 소개할 수 있는 사진을 올려주세요! (최대 5장)',
                      content: MultipleImagePicker(
                        onSelect: (file) {
                          setState(() {
                            if (_findSessionUploadData.images
                                .contains(file.path)) {
                              _findSessionUploadData.images.remove(file.path);
                            } else {
                              _findSessionUploadData.images.add(file.path);
                            }
                          });
                        },
                        images: _findSessionUploadData.images
                            .map((path) => path)
                            .toList(),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomForm(
                      label: '연락처',
                      isRequired: true,
                      subTitle: '카톡 아이디 또는 오픈 카톡 프로필 링크',
                      content: TextInput(
                        focusNode: _contactFocus,
                        errorText: _contactErrorText,
                        onChanged: (value) {
                          setState(() {
                            _findSessionUploadData.contact = value;
                            _contactErrorText = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomForm(
                      label: '자세한 글',
                      content: TextInput(
                        onChanged: (value) {
                          _findSessionUploadData.description = value;
                        },
                        keyboardType: TextInputType.multiline,
                        height: 96,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    WideButton(
                      text: '게시하기',
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

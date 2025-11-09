import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/find_session_upload_model.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/upload_screen/hashtag_selector.dart';
import 'package:lets_jam/screens/upload_screen/region_selector.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/widgets/custom_form.dart';
import 'package:lets_jam/widgets/multiple_image_picker.dart';
import 'package:lets_jam/widgets/session_selector.dart';
import 'package:lets_jam/widgets/text_input.dart';
import 'package:lets_jam/widgets/wide_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: constant_identifier_names
const SUPABASE_BUCKET_NAME = 'images';

class EditPostScreen extends StatefulWidget {
  final PostModel post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contactFocus = FocusNode();

  final supabase = Supabase.instance.client;
  final SessionController sessionController = Get.find<SessionController>();

  late final FindSessionUploadModel _findSessionEditData;

  String? _titleErrorText;
  String? _contactErrorText;
  bool _sessionError = false; // 세션 선택 유효성용 flag
  bool _regionError = false;

  final _sessionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _findSessionEditData = FindSessionUploadModel.fromPost(widget.post);
  }

  Future<void> _submit() async {
    setState(() {
      _titleErrorText = null;
      _contactErrorText = null;
      _sessionError = false;
      _regionError = false;
    });

    bool hasError = false;

    if (_findSessionEditData.sessions.isEmpty) {
      setState(() => _sessionError = true);
    } else {
      setState(() => _sessionError = false);
    }
    if (_findSessionEditData.title.isEmpty) {
      _titleErrorText = '제목을 입력해주세요';
      hasError = true;
    }
    if (_findSessionEditData.sessions.isEmpty) {
      _sessionError = true;
      hasError = true;
    }
    if (_findSessionEditData.contact.isEmpty) {
      _contactErrorText = '연락처를 입력해주세요';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      if (_findSessionEditData.title.isEmpty) {
        FocusScope.of(context).requestFocus(_titleFocus);
      } else if (_findSessionEditData.sessions.isEmpty) {
        Scrollable.ensureVisible(_sessionKey.currentContext!,
            duration: const Duration(milliseconds: 300));
      } else if (_findSessionEditData.contact.isEmpty) {
        FocusScope.of(context).requestFocus(_contactFocus);
      }
      return;
    }

    _formKey.currentState!.save();
    await _savePostToSupabase();

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _savePostToSupabase() async {
    try {
      final user = sessionController.user.value;
      final String userId = user!.id;
      final List<String> imageUrls = [];

      for (var image in _findSessionEditData.images) {
        if ((widget.post.images ?? []).contains(image)) {
          imageUrls.add(image);
        } else {
          final path =
              'post_uploads/${DateTime.now().millisecondsSinceEpoch}-${image.split('/').last}';

          final response = await supabase.storage
              .from(SUPABASE_BUCKET_NAME)
              .upload(path, File(image));

          final filePath = response.replaceFirst('$SUPABASE_BUCKET_NAME/', '');

          final imagePublicUrl = supabase.storage
              .from(SUPABASE_BUCKET_NAME)
              .getPublicUrl(filePath);

          imageUrls.add(imagePublicUrl);
        }
      }

      await supabase.from('posts').update({
        'user_id': userId,
        'title': _findSessionEditData.title,
        'levels': _findSessionEditData.levels.map((el) => el.name).toList(),
        'sessions': _findSessionEditData.sessions.map((el) => el.name).toList(),
        'ages': _findSessionEditData.ages.map((el) => el.name).toList(),
        'regions':
            _findSessionEditData.regions.map((el) => el.displayName).toList(),
        'contact': _findSessionEditData.contact,
        'description': _findSessionEditData.description,
        'tags': _findSessionEditData.tags,
        'images': imageUrls,
      }).eq('id', widget.post.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(customSnackbar('게시글을 수정했습니다.'));
    } catch (err) {
      print('게시글 수정 에러: $err');
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            IconThemeData(color: ColorSeed.boldOrangeStrong.color, size: 20),
        shape: Border(
            bottom:
                BorderSide(color: ColorSeed.boldOrangeStrong.color, width: 1)),
        title: Text(
          '게시글 수정',
          style: TextStyle(
              fontSize: 16,
              color: ColorSeed.boldOrangeStrong.color,
              fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextInput(
                    label: '제목',
                    focusNode: _titleFocus,
                    initialValue: _findSessionEditData.title,
                    isRequired: true,
                    errorText: _titleErrorText,
                    onChanged: (value) {
                      setState(() {
                        _findSessionEditData.title = value;
                        _titleErrorText = null;
                      });
                    }),
                const SizedBox(
                  height: 30,
                ),
                CustomForm(
                  label: '세션',
                  subTitle: '밴드가 원하는 멤버의 세션을 모두 선택해주세요.',
                  isRequired: true,
                  content: SessionSelector(
                    selectedSessions: _findSessionEditData.sessions,
                    onChange: (session) {
                      setState(() {
                        if (_findSessionEditData.sessions.contains(session)) {
                          _findSessionEditData.sessions.remove(session);
                        } else {
                          _findSessionEditData.sessions.add(session);
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
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 30,
                ),
                CustomForm(
                  label: '지역(최대3개)',
                  content: RegionSelector(
                    selectedRegions: _findSessionEditData.regions,
                    onChange: (region) {
                      setState(() {
                        if (_findSessionEditData.regions.contains(region)) {
                          _findSessionEditData.regions.remove(region);
                          _regionError = false;
                        } else {
                          if (_findSessionEditData.regions.length >= 3) {
                            _regionError = true;
                            return;
                          }
                          _regionError = false;
                          _findSessionEditData.regions.add(region);
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
                            style: TextStyle(color: Colors.red, fontSize: 12),
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
                    selectedTags: _findSessionEditData.tags,
                    onSelect: (tag) {
                      if (_findSessionEditData.tags.contains(tag)) {
                        _findSessionEditData.tags.remove(tag);
                      } else {
                        if (_findSessionEditData.tags.length >= 5) return;
                        _findSessionEditData.tags.add(tag);
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
                        if (_findSessionEditData.images.contains(file.path)) {
                          _findSessionEditData.images.remove(file.path);
                        } else {
                          _findSessionEditData.images.add(file.path);
                        }
                      });
                    },
                    images: _findSessionEditData.images,
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
                    initialValue: _findSessionEditData.contact,
                    onChanged: (value) {
                      setState(() {
                        _findSessionEditData.contact = value;
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
                    initialValue: _findSessionEditData.description,
                    onChanged: (value) {
                      _findSessionEditData.description = value;
                    },
                    keyboardType: TextInputType.multiline,
                    height: 96,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                WideButton(
                  text: '수정하기',
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/screens/upload_screen/hashtag_selector.dart';
import 'package:lets_jam/screens/upload_screen/region_selector.dart';
import 'package:lets_jam/screens/upload_screen/upload_type_toggler.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/widgets/custom_form.dart';
import 'package:lets_jam/widgets/multiple_image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/find_session_upload_model.dart';
import 'package:lets_jam/widgets/text_input.dart';
import 'package:lets_jam/widgets/wide_button.dart';
import 'package:lets_jam/widgets/session_selector.dart';

enum PostFormMode { create, edit }

class PostFormScreen extends StatefulWidget {
  final PostFormMode mode;
  final PostModel? post;

  const PostFormScreen({
    super.key,
    required this.mode,
    this.post,
  });

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contactFocus = FocusNode();

  final supabase = Supabase.instance.client;
  final SessionController sessionController = Get.find<SessionController>();

  late FindSessionUploadModel formData;
  late PostTypeEnum postType;

  // validation용
  String? _titleErrorText;
  String? _contactErrorText;
  bool _sessionError = false;
  bool _regionError = false;

  final _sessionKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.mode == PostFormMode.edit && widget.post != null) {
      postType = widget.post!.postType;
      formData = FindSessionUploadModel.fromPost(widget.post!);
    } else {
      postType = PostTypeEnum.findMember; // 기본값
      formData = FindSessionUploadModel.init();
    }
  }

  void _selectUploadType(PostTypeEnum type) {
    setState(() {
      postType = type;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _titleErrorText = null;
      _contactErrorText = null;
      _sessionError = false;
      _regionError = false;
    });

    bool hasError = false;

    if (formData.title.trim().isEmpty) {
      _titleErrorText = '제목을 입력해주세요';
      hasError = true;
    }
    if (formData.sessions.isEmpty) {
      _sessionError = true;
      hasError = true;
    }
    if (formData.regions.isEmpty) {
      _regionError = true;
      hasError = true;
    }
    if (formData.contact.trim().isEmpty) {
      _contactErrorText = '연락처를 입력해주세요';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      if (formData.title.isEmpty) {
        FocusScope.of(context).requestFocus(_titleFocus);
      } else if (formData.sessions.isEmpty) {
        Scrollable.ensureVisible(_sessionKey.currentContext!,
            duration: const Duration(milliseconds: 300));
      } else if (formData.contact.isEmpty) {
        FocusScope.of(context).requestFocus(_contactFocus);
      }
      return;
    }

    try {
      if (widget.mode == PostFormMode.create) {
        await _insertPost();
      } else {
        await _updatePost();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackbar(widget.mode == PostFormMode.create
            ? '게시글을 작성했습니다.'
            : '게시글을 수정했습니다.'),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('저장 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(customSnackbar('저장 실패: $e'));
    }
  }

  Future<void> _insertPost() async {
    final user = sessionController.user.value;
    final userId = user!.id;

    final imageUrls = await _uploadImages(formData.images);

    await supabase.from('posts').insert({
      'user_id': userId,
      'title': formData.title,
      'levels': formData.levels.map((e) => e.name).toList(),
      'sessions': formData.sessions.map((e) => e.name).toList(),
      'ages': formData.ages.map((e) => e.name).toList(),
      'regions': formData.regions.map((e) => e.displayName).toList(),
      'contact': formData.contact,
      'description': formData.description,
      'tags': formData.tags,
      'images': imageUrls,
      'post_type': postType.name,
    });
  }

  Future<void> _updatePost() async {
    final user = sessionController.user.value;
    final userId = user!.id;

    final prevImages = widget.post!.images ?? [];
    final imageUrls = <String>[];

    for (final img in formData.images) {
      if (prevImages.contains(img)) {
        imageUrls.add(img);
      } else {
        final uploaded = await _uploadImages([img]);
        imageUrls.addAll(uploaded);
      }
    }

    await supabase.from('posts').update({
      'user_id': userId,
      'title': formData.title,
      'levels': formData.levels.map((e) => e.name).toList(),
      'sessions': formData.sessions.map((e) => e.name).toList(),
      'ages': formData.ages.map((e) => e.name).toList(),
      'regions': formData.regions.map((e) => e.displayName).toList(),
      'contact': formData.contact,
      'description': formData.description,
      'tags': formData.tags,
      'images': imageUrls,
    }).eq('id', widget.post!.id);
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
          'post_uploads/${DateTime.now().millisecondsSinceEpoch}-${image.split('/').last}';
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
      appBar: AppBar(
        title: Text(
          widget.mode == PostFormMode.create ? '글쓰기' : '게시글 수정',
          style: TextStyle(
              fontSize: 16,
              color: ColorSeed.boldOrangeStrong.color,
              fontWeight: FontWeight.w500),
        ),
        forceMaterialTransparency: true,
        backgroundColor: ColorSeed.boldOrangeLight.color,
        elevation: 0,
        iconTheme:
            IconThemeData(color: ColorSeed.boldOrangeStrong.color, size: 20),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          child: Column(
            children: [
              if (widget.mode == PostFormMode.create)
                Column(
                  children: [
                    UploadTypeToggler(
                        onSelect: _selectUploadType, selectedType: postType),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextInput(
                      label: '제목',
                      focusNode: _titleFocus,
                      initialValue: formData.title,
                      isRequired: true,
                      errorText: _titleErrorText,
                      onChanged: (value) {
                        setState(() {
                          formData.title = value;
                          _titleErrorText = null;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomForm(
                      label: '세션',
                      subTitle: postType == PostTypeEnum.findBand
                          ? '밴드에서 하고 싶은 세션을 선택해주세요 (최대 2개)'
                          : '밴드가 원하는 멤버의 세션을 모두 선택해주세요.',
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
                        selectedRegions: formData.regions,
                        onChange: (region) {
                          setState(() {
                            if (formData.regions.contains(region)) {
                              formData.regions.remove(region);
                              _regionError = false;
                            } else {
                              if (formData.regions.length >= 3) {
                                _regionError = true;
                                return;
                              }
                              _regionError = false;
                              formData.regions.add(region);
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
                      subTitle: '자유롭게 작성해주세요 (최대 5개) 예) #대학생밴드 #데이식스 #메탈',
                      content: HashTagSelector(
                        selectedTags: formData.tags,
                        onSelect: (tag) {
                          if (formData.tags.contains(tag)) {
                            formData.tags.remove(tag);
                          } else {
                            if (formData.tags.length >= 5) return;
                            formData.tags.add(tag);
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomForm(
                      label: '사진',
                      subTitle: '나를 소개할 수 있는 사진을 올려주세요 (최대 5장)',
                      content: MultipleImagePicker(
                          onSelect: (file) {
                            setState(() {
                              if (formData.images.contains(file.path)) {
                                formData.images.remove(file.path);
                              } else {
                                formData.images.add(file.path);
                              }
                            });
                          },
                          images: formData.images),
                    ),
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
                      label: '자세한 글',
                      subTitle: '함께 하고 싶은 음악 스타일, 연습 일정 등을 적어 주세요',
                      content: TextInput(
                        initialValue: formData.description,
                        onChanged: (value) {
                          formData.description = value;
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

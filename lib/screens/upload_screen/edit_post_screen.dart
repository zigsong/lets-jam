import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/find_session_upload_model.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/upload_screen/age_selector.dart';
import 'package:lets_jam/screens/upload_screen/level_selector.dart';
import 'package:lets_jam/screens/upload_screen/region_selector.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/widgets/custom_form.dart';
import 'package:lets_jam/widgets/multiple_image_picker.dart';
import 'package:lets_jam/widgets/session_selector.dart';
import 'package:lets_jam/widgets/text_input.dart';
import 'package:lets_jam/widgets/wide_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const SUPABASE_BUCKET_NAME = 'images';

class EditPostScreen extends StatefulWidget {
  final PostModel post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  // Map<UploadRequiredEnum, bool> valiators = {};
  final supabase = Supabase.instance.client;
  final SessionController sessionController = Get.find<SessionController>();

  late final FindSessionUploadModel _findSessionEditData;

  @override
  void initState() {
    super.initState();
    _findSessionEditData = FindSessionUploadModel.fromPost(widget.post);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await _savePostToSupabase();

      Navigator.pop(context, true);
    }
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
        'regions': _findSessionEditData.regions.toList(),
        'contact': _findSessionEditData.contact,
        'description': _findSessionEditData.description,
        'images': imageUrls,
      }).eq('id', widget.post.id);

      ScaffoldMessenger.of(context)
          .showSnackBar(customSnackbar('게시글을 수정했습니다.'));
    } catch (err) {
      print('게시글 수정 에러: $err');
    }
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
                    initialValue: _findSessionEditData.title,
                    isRequired: true,
                    onChange: (value) {
                      _findSessionEditData.title = value ?? '';
                    }),
                const SizedBox(
                  height: 30,
                ),
                CustomForm(
                  label: '레벨',
                  subTitle: '밴드가 원하는 세션의 연주 레벨을 모두 선택해주세요.',
                  isRequired: true,
                  content: LevelSelector(
                    selectedLevels: _findSessionEditData.levels,
                    onChange: (level) {
                      if (level == null) {
                        setState(() {
                          _findSessionEditData.levels = [];
                        });
                        return;
                      }
                      if (_findSessionEditData.levels.contains(level)) {
                        debugPrint('해제: $level');
                        _findSessionEditData.levels.remove(level);
                      } else {
                        debugPrint('선택: $level');
                        _findSessionEditData.levels.add(level);
                      }
                    },
                  ),
                ),
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
                      if (_findSessionEditData.sessions.contains(session)) {
                        _findSessionEditData.sessions.remove(session);
                      } else {
                        _findSessionEditData.sessions.add(session);
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomForm(
                  label: '연령대',
                  content: AgeSelector(
                    selectedAges: _findSessionEditData.ages,
                    onChange: (age) {
                      if (age == null) {
                        setState(() {
                          _findSessionEditData.ages = [];
                        });
                        return;
                      }

                      if (_findSessionEditData.ages.contains(age)) {
                        _findSessionEditData.ages.remove(age);
                      } else {
                        _findSessionEditData.ages.add(age);
                      }
                    },
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
                      if (_findSessionEditData.regions.contains(region)) {
                        _findSessionEditData.regions.remove(region);
                      } else {
                        /** TODO: 3개 이상 선택 시도 시 알럿 */
                        if (_findSessionEditData.regions.length >= 3) return;
                        _findSessionEditData.regions.add(region);
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
                  subTitle: '카톡 아이디 또는 오픈 카톡 프로필 링크',
                  content: TextInput(
                    initialValue: _findSessionEditData.contact,
                    onChange: (value) {
                      _findSessionEditData.contact = value ?? '';
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
                    onChange: (value) {
                      _findSessionEditData.description = value ?? '';
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
                  onPressed: () async {
                    await _submit();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

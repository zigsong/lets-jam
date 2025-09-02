import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/models/find_session_upload_model.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:lets_jam/screens/upload_screen/age_selector.dart';
import 'package:lets_jam/screens/upload_screen/region_selector.dart';
import 'package:lets_jam/screens/upload_screen/tag_selector.dart';
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

const SUPABASE_BUCKET_NAME = 'images';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final PostTypeEnum postType = PostTypeEnum.findMember;
  final _formKey = GlobalKey<FormState>();
  // Map<UploadRequiredEnum, bool> valiators = {};
  final supabase = Supabase.instance.client;
  final SessionController sessionController = Get.find<SessionController>();

  final FindSessionUploadModel _findSessionUploadData =
      FindSessionUploadModel.init();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _savePostToSupabase();

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DefaultNavigation()));
    }
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
        'regions': _findSessionUploadData.regions.toList(),
        'contact': _findSessionUploadData.contact,
        'description': _findSessionUploadData.description,
        'tags': _findSessionUploadData.tags,
        'images': imageUrls,
        'post_type': postType.name,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(customSnackbar('게시글을 작성했습니다.'));
    } catch (err) {
      print('게시글 작성 에러: $err');
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
            key: _formKey,
            child: Column(
              children: [
                TextInput(
                    label: '제목',
                    isRequired: true,
                    onChange: (value) {
                      _findSessionUploadData.title = value ?? '';
                    }),
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
                      if (_findSessionUploadData.sessions.contains(session)) {
                        _findSessionUploadData.sessions.remove(session);
                      } else {
                        _findSessionUploadData.sessions.add(session);
                      }
                    },
                  ),
                ),
                // const SizedBox(
                //   height: 30,
                // ),
                // CustomForm(
                //   label: '레벨',
                //   subTitle: '밴드가 원하는 세션의 연주 레벨을 모두 선택해주세요.',
                //   isRequired: true,
                //   content: LevelSelector(
                //     selectedLevels: _findSessionUploadData.levels,
                //     onChange: (level) {
                //       if (level == null) {
                //         setState(() {
                //           _findSessionUploadData.levels = [];
                //         });
                //         return;
                //       }
                //       if (_findSessionUploadData.levels.contains(level)) {
                //         debugPrint('해제: $level');
                //         _findSessionUploadData.levels.remove(level);
                //       } else {
                //         debugPrint('선택: $level');
                //         _findSessionUploadData.levels.add(level);
                //       }
                //     },
                //   ),
                // ),
                const SizedBox(
                  height: 30,
                ),
                CustomForm(
                  label: '연령대',
                  content: AgeSelector(
                    selectedAges: _findSessionUploadData.ages,
                    onChange: (age) {
                      if (age == null) {
                        setState(() {
                          _findSessionUploadData.ages = [];
                        });
                        return;
                      }

                      if (_findSessionUploadData.ages.contains(age)) {
                        _findSessionUploadData.ages.remove(age);
                      } else {
                        _findSessionUploadData.ages.add(age);
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
                    selectedRegions: _findSessionUploadData.regions,
                    onChange: (region) {
                      if (_findSessionUploadData.regions.contains(region)) {
                        _findSessionUploadData.regions.remove(region);
                      } else {
                        /** TODO: 3개 이상 선택 시도 시 알럿 */
                        if (_findSessionUploadData.regions.length >= 3) return;
                        _findSessionUploadData.regions.add(region);
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomForm(
                  label: '해시태그',
                  subTitle: '자유롭게 작성해주세요 (최대 5개)',
                  content: TagSelector(
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
                        if (_findSessionUploadData.images.contains(file.path)) {
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
                  subTitle: '카톡 아이디 또는 오픈 카톡 프로필 링크',
                  content: TextInput(
                    onChange: (value) {
                      _findSessionUploadData.contact = value ?? '';
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomForm(
                  label: '자세한 글',
                  content: TextInput(
                    onChange: (value) {
                      _findSessionUploadData.description = value ?? '';
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
        ),
      ),
    );
  }
}

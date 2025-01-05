import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/find_session_upload_model.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:lets_jam/utils/auth.dart';
import 'package:lets_jam/widgets/custom_form.dart';
import 'package:lets_jam/widgets/multiple_image_picker.dart';
import 'package:lets_jam/widgets/session_selector.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:lets_jam/widgets/text_input.dart';
import 'package:lets_jam/widgets/wide_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum PostTypeEnum { findBand, findSession }

Map<PostTypeEnum, String> postTypeTitle = {
  PostTypeEnum.findBand: '밴드',
  PostTypeEnum.findSession: '세션',
};

const SUPABASE_BUCKET_NAME = 'images';

class UploadScreen extends StatefulWidget {
  final PostTypeEnum postType;
  const UploadScreen({super.key, required this.postType});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  // Map<UploadRequiredEnum, bool> valiators = {};
  final supabase = Supabase.instance.client;

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

  Future<void> _savePostToSupabase() async {
    try {
      final user = await getUser();
      final String userId = user?['id'];
      final List<String> imageUrls = [];

      for (var image in _findSessionUploadData.images) {
        final path =
            'post_uploads/${DateTime.now().millisecondsSinceEpoch}-${image.path.split('/').last}';

        final response = await supabase.storage
            .from(SUPABASE_BUCKET_NAME)
            .upload(path, File(image.path));

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
        'images': imageUrls,
        // 'band_profile': ...,
        'post_type': widget.postType.name,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글을 작성했습니다.')),
      );
    } catch (err) {
      print('게시글 작성 에러: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${postTypeTitle[widget.postType]} 구하기',
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: const Color(0xffF2F2F2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextInput(
                    label: '제목',
                    onChange: (value) {
                      _findSessionUploadData.title = value ?? '';
                    }),
                const SizedBox(
                  height: 20,
                ),
                CustomForm(
                  label: '레벨',
                  subTitle: '밴드가 원하는 세션의 레벨을 모두 선택해주세요.',
                  content: LevelSelector(
                    selectedLevels: _findSessionUploadData.levels,
                    onChange: (level) {
                      if (_findSessionUploadData.levels.contains(level)) {
                        _findSessionUploadData.levels.remove(level);
                      } else {
                        _findSessionUploadData.levels.add(level);
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomForm(
                  label: '세션',
                  subTitle: '밴드가 구하는 세션을 모두 선택해주세요.',
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
                const SizedBox(
                  height: 20,
                ),
                CustomForm(
                  label: '연령대',
                  content: AgeSelector(
                    selectedAges: _findSessionUploadData.ages,
                    onChange: (age) {
                      if (_findSessionUploadData.ages.contains(age)) {
                        _findSessionUploadData.ages.remove(age);
                      } else {
                        _findSessionUploadData.ages.add(age);
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomForm(
                  label: '지역',
                  content: RegionSelector(
                    selectedRegions: _findSessionUploadData.regions,
                    onChange: (region) {
                      if (_findSessionUploadData.regions.contains(region)) {
                        _findSessionUploadData.regions.remove(region);
                      } else {
                        _findSessionUploadData.regions.add(region);
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomForm(
                  label: '연락처',
                  subTitle: '카톡아이디 또는 오픈카톡프로필 링크',
                  content: TextInput(onChange: (value) {
                    _findSessionUploadData.contact = value ?? '';
                  }),
                ),
                const SizedBox(
                  height: 20,
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
                  height: 20,
                ),
                CustomForm(
                  label: '사진',
                  subTitle: '밴드를 소개할 수 있는 사진을 올려주세요!(최대 5장)',
                  content: MultipleImagePicker(
                    onSelect: (file) {
                      setState(() {
                        if (_findSessionUploadData.images.contains(file)) {
                          _findSessionUploadData.images.remove(file);
                        } else {
                          _findSessionUploadData.images.add(file);
                        }
                      });
                    },
                    images: _findSessionUploadData.images,
                  ),
                ),
                const SizedBox(
                  height: 20,
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

class LevelSelector extends StatefulWidget {
  final List<LevelEnum> selectedLevels;
  final Function(LevelEnum level) onChange;

  const LevelSelector(
      {super.key, required this.selectedLevels, required this.onChange});

  @override
  State<LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<LevelSelector> {
  @override
  Widget build(BuildContext context) {
    return Row(
        children: levelMap.entries.map((entry) {
      bool isSelected = widget.selectedLevels.contains(entry.key);

      return Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                widget.onChange(entry.key);
              });
            },
            child: Tag(
                text: entry.value,
                size: TagSizeEnum.small,
                bgColor: isSelected
                    ? const Color(0xffBFFFAF)
                    : const Color(0xffD5D5D5)),
          ),
          if (entry != levelMap.entries.last) // 마지막 요소에는 간격 추가하지 않음
            const SizedBox(width: 6), // 항목 사이 간격
        ],
      );
    }).toList());
  }
}

class AgeSelector extends StatefulWidget {
  final List<AgeEnum> selectedAges;
  final Function(AgeEnum age) onChange;

  const AgeSelector(
      {super.key, required this.selectedAges, required this.onChange});

  @override
  State<AgeSelector> createState() => _AgeSelectorState();
}

class _AgeSelectorState extends State<AgeSelector> {
  @override
  Widget build(BuildContext context) {
    return Row(
        children: ageMap.entries.map((entry) {
      bool isSelected = widget.selectedAges.contains(entry.key);

      return Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                widget.onChange(entry.key);
              });
            },
            child: Tag(
                text: entry.value,
                size: TagSizeEnum.small,
                bgColor: isSelected
                    ? const Color(0xffBFFFAF)
                    : const Color(0xffD5D5D5)),
          ),
          if (entry != ageMap.entries.last) // 마지막 요소에는 간격 추가하지 않음
            const SizedBox(width: 6), // 항목 사이 간격
        ],
      );
    }).toList());
  }
}

class RegionSelector extends StatefulWidget {
  final List<String> selectedRegions;
  final Function(String region) onChange;

  const RegionSelector(
      {super.key, required this.selectedRegions, required this.onChange});

  @override
  State<RegionSelector> createState() => _RegionSelectorState();
}

class _RegionSelectorState extends State<RegionSelector> {
  /// MARK: 얘 어따 두지?
  final List<String> regions = ['서울', '인천', '경기', '충청', '대전', '광주', '부산', '제주'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: widget.selectedRegions.asMap().entries.map((entry) {
            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.onChange(entry.value);
                    });
                  },
                  child: Tag(
                      text: entry.value,
                      size: TagSizeEnum.small,
                      bgColor: const Color(0xffBFFFAF)),
                ),
                if (entry !=
                    widget.selectedRegions
                        .asMap()
                        .entries
                        .last) // 마지막 요소에는 간격 추가하지 않음
                  const SizedBox(width: 6), // 항목 사이 간격
              ],
            );
          }).toList()),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          height: 192,
          /** NOTE: borderRadius를 넘는 이슈 때문에 임시로 padding을 사용 */
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              border: Border.all(width: 2, color: const Color(0xffAED3FF)),
              borderRadius: BorderRadius.circular(12)),
          child: SingleChildScrollView(
            child: Column(
              children: regions
                  .asMap()
                  .entries
                  .map((entry) => Material(
                        child: InkWell(
                          splashColor: const Color(0xffAED3FF),
                          highlightColor: const Color(0xffAED3FF),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              width: double.infinity,
                              height: 48,
                              child: Text(entry.value)),
                          onTap: () {
                            setState(() {
                              widget.onChange(entry.value);
                            });
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

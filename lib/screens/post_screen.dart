import 'package:flutter/material.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/find_session_model.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/widgets/custom_form.dart';
import 'package:lets_jam/widgets/session_selector.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:lets_jam/widgets/text_input.dart';

enum PostTypeEnum { findBand, findSession }

Map<PostTypeEnum, String> postTypeTitle = {
  PostTypeEnum.findBand: '밴드',
  PostTypeEnum.findSession: '세션',
};

/// TODO: 이름 바꾸기 - UploadScreen
class PostScreen extends StatefulWidget {
  final PostTypeEnum postType;
  const PostScreen({super.key, required this.postType});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final FindSessionModel _findSessionData = FindSessionModel.init();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${postTypeTitle[widget.postType]} 구하기',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: const Color(0xffF2F2F2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Column(
            children: [
              TextInput(
                  label: '제목',
                  onChange: (value) {
                    print('제목: $value');
                  }),
              const SizedBox(
                height: 20,
              ),
              CustomForm(
                label: '레벨',
                subTitle: '밴드가 원하는 세션의 레벨을 모두 선택해주세요.',
                content: LevelSelector(
                  selectedLevels: _findSessionData.levels,
                  onChange: (level) {
                    if (_findSessionData.levels.contains(level)) {
                      _findSessionData.levels.remove(level);
                    } else {
                      _findSessionData.levels.add(level);
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
                  selectedSessions: _findSessionData.sessions,
                  onChange: (session) {
                    if (_findSessionData.sessions.contains(session)) {
                      _findSessionData.sessions.remove(session);
                    } else {
                      _findSessionData.sessions.add(session);
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
                  selectedAges: _findSessionData.ages,
                  onChange: (age) {
                    if (_findSessionData.ages.contains(age)) {
                      _findSessionData.ages.remove(age);
                    } else {
                      _findSessionData.ages.add(age);
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
                  selectedRegions: _findSessionData.regions,
                  onChange: (region) {
                    if (_findSessionData.regions.contains(region)) {
                      _findSessionData.regions.remove(region);
                    } else {
                      _findSessionData.regions.add(region);
                    }
                  },
                ),
              ),
            ],
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
          decoration: BoxDecoration(
              border: const Border(
                  top: BorderSide(width: 2, color: Color(0xffAED3FF))),
              borderRadius: BorderRadius.circular(12)),
          child: SingleChildScrollView(
            child: Column(
              children: regions
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
                              height: 48,
                              decoration: BoxDecoration(
                                border: entry.key > 0
                                    ? const Border(
                                        top: BorderSide(
                                            width: 2, color: Color(0xffAED3FF)),
                                      )
                                    : null,
                              ),
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

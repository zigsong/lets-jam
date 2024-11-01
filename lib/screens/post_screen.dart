import 'package:flutter/material.dart';
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:lets_jam/widgets/tag.dart';
import 'package:lets_jam/widgets/text_input.dart' as CustomInput;

class HashTagSelector extends StatefulWidget {
  const HashTagSelector(
      {super.key, required this.selectedTags, required this.onSelect});

  final List<String> selectedTags;
  final Function(String tag) onSelect;

  @override
  State<HashTagSelector> createState() => _HashTagSelectorState();
}

class _HashTagSelectorState extends State<HashTagSelector> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = "#";

    // 텍스트 변경 리스너
    _textEditingController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onTextChanged);
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textEditingController.text;
    final cursorPosition = _textEditingController.selection.start;

    // # 제거 방지
    if (!text.startsWith('#')) {
      _textEditingController.text = '#$text';
      _textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textEditingController.text.length),
      );
      return;
    }

    // # 중간에 있는 # 앞의 문자가 삭제되는 것 방지
    if (text.contains('#') && cursorPosition > 0) {
      final beforeCursor = text.substring(0, cursorPosition);
      final afterCursor = text.substring(cursorPosition);

      // 커서 앞에 #이 있고 그 앞에 문자가 없다면 (즉, 맨 앞의 #을 지우려 했다면)
      if (beforeCursor.endsWith('#') && beforeCursor.length == 1) {
        return; // 변경 무시
      }
    }

    // 스페이스바 감지해서 새 해시태그 시작
    if (text.endsWith(' ') && text.length > 1) {
      final newText = '${text.trim()} #';
      _textEditingController.text = newText;
      _textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    }
  }

  void _onSubmit() {
    // 현재 입력된 해시태그들 추가하고 키보드 닫기
    String value = _textEditingController.text.trim();
    if (value.isNotEmpty && value != '#') {
      // 현재 입력된 해시태그들을 파싱
      List<String> tags = value
          .split(' ')
          .where((tag) => tag.isNotEmpty && tag != '#')
          .toList();

      // 각 태그를 선택된 태그에 추가
      for (String tag in tags) {
        if (!widget.selectedTags.contains(tag)) {
          setState(() {
            widget.onSelect(tag);
          });
        }
      }
    }

    // 입력 필드 리셋하고 키보드 닫기
    _textEditingController.text = '#';
    _textEditingController.selection = TextSelection.fromPosition(
      const TextPosition(offset: 1),
    );
    _focusNode.unfocus();
  }

  void _removeLastTag() {
    if (widget.selectedTags.isNotEmpty) {
      setState(() {
        widget.selectedTags.removeLast();
      });
    }
  }

  bool _onKeyEvent(KeyEvent event) {
    // 엔터 키 감지
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      _onSubmit();
      return true;
    }

    // 백스페이스로 태그 삭제 또는 # 제거 방지
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      final text = _textEditingController.text;
      final cursorPosition = _textEditingController.selection.start;

      // 입력 필드가 "#"만 있고 커서가 맨 뒤에 있을 때 -> 이전 태그 삭제
      if (text == '#' &&
          cursorPosition == 1 &&
          widget.selectedTags.isNotEmpty) {
        _removeLastTag();
        return true; // 이벤트 소비
      }

      // 맨 앞의 첫 번째 # 제거 시도하면 막기
      if (cursorPosition == 1 && text.startsWith('#')) {
        return true; // 이벤트 소비해서 백스페이스 동작 막기
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wrap(
        //   spacing: 8,
        //   runSpacing: 8,
        //   children: widget.selectedTags.map((tag) {
        //     return GestureDetector(
        //       onTap: () {
        //         setState(() {
        //           widget.selectedTags.remove(tag);
        //         });
        //       },
        //       child: Tag(
        //         text: tag,
        //         color: TagColorEnum.black,
        //         size: TagSizeEnum.small,
        //         selected: true,
        //       ),
        //     );
        //   }).toList(),
        // ),
        const SizedBox(height: 8),
        Focus(
          onKeyEvent: (node, event) {
            return _onKeyEvent(event)
                ? KeyEventResult.handled
                : KeyEventResult.ignored;
          },
          child: CustomInput.TextInput(
            controller: _textEditingController,
            focusNode: _focusNode,
            onSubmit: _onSubmit,
          ),
        ),
      ],
    );
  }
}

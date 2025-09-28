import 'package:flutter/material.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:lets_jam/widgets/text_input.dart';

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

  @override
  void initState() {
    super.initState();
    _textEditingController.text = "#";

    _textEditingController.addListener(() {
      String text = _textEditingController.text;
      if (!text.startsWith('#') || text.isEmpty) {
        _textEditingController.value = const TextEditingValue(
          text: '#',
          selection: TextSelection.collapsed(offset: 1),
        );
      }
    });
  }

  void _submit() {
    String value = _textEditingController.text;
    if (value == '#' || value.trim().isEmpty) return;

    setState(() {
      widget.onSelect(value);
    });

    _textEditingController.text = '#';
    _textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textEditingController.text.length), // 커서를 맨 끝으로
    );
  }

  void _onChanged(String value) {
    if (value.endsWith(' ')) {
      _submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.selectedTags.map((tag) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  widget.selectedTags.remove(tag);
                });
              },
              child: Tag(
                text: tag,
                color: TagColorEnum.black,
                size: TagSizeEnum.small,
                selected: true,
              ),
            );
          }).toList(),
        ),
        const SizedBox(
          height: 8,
        ),
        TextInput(
          controller: _textEditingController,
          onSubmit: _submit,
          onChanged: _onChanged,
        ),
      ],
    );
  }
}

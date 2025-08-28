import 'package:flutter/material.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:lets_jam/widgets/text_input.dart';

class TagSelector extends StatefulWidget {
  const TagSelector(
      {super.key, required this.selectedTags, required this.onSelect});

  final List<String> selectedTags;
  final Function(String tag) onSelect;

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  String _value = '';
  final TextEditingController _textEditingController = TextEditingController();

  void _submit() {
    if (_value == '') return;

    widget.onSelect(_value);

    final content = _textEditingController.text;
    if (content.isNotEmpty) {
      _textEditingController.clear();

      setState(() {
        _value = '';
      });
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
                withXIcon: true,
              ),
            );
          }).toList(),
        ),
        const SizedBox(
          height: 8,
        ),
        TextInput(
            controller: _textEditingController,
            placeholder: widget.selectedTags.isEmpty ? '#대학생밴드 #데이식스 #메탈' : '',
            onChange: (value) {
              setState(() {
                _value = value;
              });
            },
            onSubmit: _submit),
      ],
    );
  }
}

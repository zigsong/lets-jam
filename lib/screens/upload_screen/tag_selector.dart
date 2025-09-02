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
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = "#";
  }

  void _submit() {
    String value = _textEditingController.text;
    if (value == '') return;

    setState(() {
      widget.onSelect(value);
    });

    _textEditingController.text = '#';
    _textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textEditingController.text.length), // 커서를 맨 끝으로
    );
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
        TextInput(controller: _textEditingController, onSubmit: _submit),
      ],
    );
  }
}

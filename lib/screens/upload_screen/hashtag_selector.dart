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
  final FocusNode _focusNode = FocusNode();

  void _submit() {
    String value = _textEditingController.text;
    if (value.trim().isEmpty) return;

    setState(() {
      widget.onSelect('#$value');
    });

    _textEditingController.text = '';
    // 포커스를 유지해 키보드가 내려가지 않게 함
    _focusNode.requestFocus();
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
          focusNode: _focusNode,
          onSubmit: _submit,
          onChanged: _onChanged,
          prefixText: '#',
        ),
      ],
    );
  }
}

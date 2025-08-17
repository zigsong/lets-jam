import 'package:flutter/material.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:lets_jam/widgets/text_input.dart';

class TagSelector extends StatefulWidget {
  const TagSelector({super.key});

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  String _value = '';
  final List<String> _selectedTags = [];
  final TextEditingController _textEditingController = TextEditingController();

  void _submit() {
    if (_value == '') return;

    setState(() {
      _selectedTags.add(_value);
    });

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
          children: _selectedTags.map((tag) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTags.remove(tag);
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
            placeholder: '#메탈 #국내팝 #인디',
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

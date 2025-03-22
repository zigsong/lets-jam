import 'package:flutter/material.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/widgets/tag.dart';

class LevelSelector extends StatefulWidget {
  final List<LevelEnum> selectedLevels;
  final Function(LevelEnum? level) onChange;

  const LevelSelector(
      {super.key, required this.selectedLevels, required this.onChange});

  @override
  State<LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<LevelSelector> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        GestureDetector(
          onTap: () {
            setState(() {
              widget.onChange(null);
            });
          },
          child: Tag(
            text: '전체',
            color: TagColorEnum.black,
            selected: widget.selectedLevels.isEmpty,
          ),
        ),
        const SizedBox(width: 6),
        ...levelMap.entries.map((entry) {
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
                  color: TagColorEnum.black,
                  selected: isSelected,
                ),
              ),
              if (entry != levelMap.entries.last) const SizedBox(width: 6),
            ],
          );
        }),
      ]),
    );
  }
}

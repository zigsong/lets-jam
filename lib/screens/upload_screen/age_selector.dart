import 'package:flutter/material.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/widgets/tag.dart';

class AgeSelector extends StatefulWidget {
  final List<AgeEnum> selectedAges;
  final Function(AgeEnum? age) onChange;

  const AgeSelector(
      {super.key, required this.selectedAges, required this.onChange});

  @override
  State<AgeSelector> createState() => _AgeSelectorState();
}

class _AgeSelectorState extends State<AgeSelector> {
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
            selected: widget.selectedAges.isEmpty,
          ),
        ),
        const SizedBox(width: 6),
        ...ageMap.entries.map((entry) {
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
                  color: TagColorEnum.black,
                  selected: isSelected,
                ),
              ),
              if (entry != ageMap.entries.last) // 마지막 요소에는 간격 추가하지 않음
                const SizedBox(width: 6), // 항목 사이 간격
            ],
          );
        }),
      ]),
    );
  }
}

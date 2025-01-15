import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class FilterTag extends StatefulWidget {
  final String text;

  const FilterTag({super.key, required this.text});

  @override
  State<FilterTag> createState() => _FilterTagState();
}

class _FilterTagState extends State<FilterTag> {
  bool _isSelected = false;

  void _toggleFilterTag() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFilterTag,
      child: Container(
        decoration: BoxDecoration(
            color:
                _isSelected ? ColorSeed.boldOrangeStrong.color : Colors.white,
            border: _isSelected
                ? Border.all(width: 2, color: Colors.transparent)
                : Border.all(width: 2, color: ColorSeed.boldOrangeStrong.color),
            borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 12),
        child: Text(
          widget.text,
          style: TextStyle(
              color:
                  _isSelected ? Colors.white : ColorSeed.boldOrangeStrong.color,
              fontSize: 16,
              height: 1.25),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BirthYearPicker extends StatefulWidget {
  final Function(DateTime birthDate) onSelect;

  const BirthYearPicker({super.key, required this.onSelect});

  @override
  State<BirthYearPicker> createState() => _BirthYearPickerState();
}

class _BirthYearPickerState extends State<BirthYearPicker> {
  int _selectedYear = DateTime.now().year;

  void _showYearPicker(BuildContext context) {
    final int currentYear = DateTime.now().year;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 200,
        color: Colors.white,
        child: CupertinoPicker(
          itemExtent: 32.0,
          scrollController: FixedExtentScrollController(
            initialItem: _selectedYear - 1900,
          ),
          onSelectedItemChanged: (int index) {
            setState(() {
              _selectedYear = 1900 + index; // 선택된 연도를 업데이트
            });
          },
          children: List<Widget>.generate(
            currentYear - 1900 + 1,
            (int index) => Center(child: Text((1900 + index).toString())),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '출생연도',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 4,
        ),
        SizedBox(
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showYearPicker(context),
            child: Text(
              '$_selectedYear',
              style: const TextStyle(
                  color: CupertinoColors.activeBlue, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}

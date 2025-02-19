import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class BirthYearPicker extends StatefulWidget {
  final Function(DateTime birthDate) onSelect;

  const BirthYearPicker({super.key, required this.onSelect});

  @override
  State<BirthYearPicker> createState() => _BirthYearPickerState();
}

class _BirthYearPickerState extends State<BirthYearPicker> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    final int currentYear = DateTime.now().year;
    final List<int> years =
        List.generate(currentYear - 1900 + 1, (index) => 1900 + index);
    final List<int> months = List.generate(12, (index) => index + 1);

    return Column(
      children: [
        Row(
          children: [
            Text(
              '나이',
              style: TextStyle(
                  fontSize: 13, color: ColorSeed.organizedBlackMedium.color),
            ),
            const SizedBox(
              width: 2,
            ),
            Text('*', style: TextStyle(color: ColorSeed.boldOrangeStrong.color))
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Container(
                height: 48,
                padding: const EdgeInsets.only(left: 16, right: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: ColorSeed.meticulousGrayLight.color, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: ColorSeed.meticulousGrayMedium.color),
                    items: years.map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: Container(
                height: 48,
                padding: const EdgeInsets.only(left: 16, right: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: ColorSeed.meticulousGrayLight.color, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: ColorSeed.meticulousGrayMedium.color),
                    items: months.map((month) {
                      return DropdownMenuItem<int>(
                        value: month,
                        child: Text(month.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

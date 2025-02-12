import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class RegionFilter extends StatefulWidget {
  const RegionFilter({super.key});

  @override
  State<RegionFilter> createState() => _RegionFilterState();
}

class _RegionFilterState extends State<RegionFilter> {
  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder(
        top:
            BorderSide(width: 0.5, color: ColorSeed.meticulousGrayMedium.color),
        bottom:
            BorderSide(width: 0.5, color: ColorSeed.meticulousGrayMedium.color),
        verticalInside:
            BorderSide(width: 0.5, color: ColorSeed.meticulousGrayMedium.color),
      ),
      columnWidths: const {
        0: FlexColumnWidth(108), // 첫 번째 열 비율
        1: FlexColumnWidth(274), // 두 번째 열 비율
      },
      children: [
        TableRow(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("서울"),
                ),
                Divider(
                  thickness: 0.5,
                  color: ColorSeed.meticulousGrayMedium.color,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("경기/인천"),
                ),
                Divider(
                  thickness: 0.5,
                  color: ColorSeed.meticulousGrayMedium.color,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text(""),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              /** TODO: ... */
              child: const Text("지역 목록 뽑아오기..."),
            ),
          ],
        ),
      ],
    );
  }
}

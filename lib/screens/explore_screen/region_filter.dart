import 'package:flutter/material.dart';
import 'package:lets_jam/models/region_enum.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegionFilter extends StatefulWidget {
  const RegionFilter(
      {super.key, required this.selectedRegions, required this.toggleRegion});

  final List<District> selectedRegions;
  final void Function(District region) toggleRegion;

  @override
  State<RegionFilter> createState() => _RegionFilterState();
}

class _RegionFilterState extends State<RegionFilter> {
  final supabase = Supabase.instance.client;
  Province? _selectedProvince = Province.values.first;

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
            SingleChildScrollView(
              child: Column(
                children: [
                  ...Province.values.map((province) => Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedProvince = province;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: _selectedProvince == province
                                      ? ColorSeed.organizedBlackMedium.color
                                      : Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  province.displayName,
                                  style: TextStyle(
                                      color: _selectedProvince == province
                                          ? Colors.white
                                          : ColorSeed
                                              .organizedBlackMedium.color),
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            height: 0.5,
                            color: ColorSeed.meticulousGrayMedium.color,
                          ),
                        ],
                      )),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: const Text(""),
                  ),
                ],
              ),
            ),
            if (_selectedProvince != null)
              Container(
                height: 176,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: District.getByProvince(_selectedProvince!)
                          .map((district) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    widget.toggleRegion(district);
                                  });
                                },
                                child: Tag(
                                  text: district.displayName,
                                  color: TagColorEnum.black,
                                  selected:
                                      widget.selectedRegions.contains(district),
                                ),
                              ))
                          .toList()),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

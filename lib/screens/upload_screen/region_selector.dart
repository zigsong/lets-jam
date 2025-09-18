import 'package:flutter/material.dart';
import 'package:lets_jam/models/region_enum.dart';
import 'package:lets_jam/widgets/custom_dropdown.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegionItem {
  final String id;
  final String text;

  RegionItem({required this.id, required this.text});
}

class RegionSelector extends StatefulWidget {
  final List<District> selectedRegions;
  final Function(District region) onChange;

  const RegionSelector(
      {super.key, required this.selectedRegions, required this.onChange});

  @override
  State<RegionSelector> createState() => _RegionSelectorState();
}

class _RegionSelectorState extends State<RegionSelector> {
  final supabase = Supabase.instance.client;

  late Province _selectedProvince;
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.selectedRegions.asMap().entries.map((entry) {
            bool isSelected = widget.selectedRegions.contains(entry.value);

            return GestureDetector(
              onTap: () {
                setState(() {
                  widget.onChange(entry.value);
                });
              },
              child: Tag(
                text: entry.value.displayName,
                color: TagColorEnum.black,
                size: TagSizeEnum.small,
                selected: isSelected,
                withXIcon: true,
              ),
            );
          }).toList(),
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: CustomDropdown(
                currentValue: DropdownItem<Province>(
                    value: _selectedProvince,
                    text: _selectedProvince.displayName),
                options: Province.values
                    .map((province) => DropdownItem(
                        value: province, text: province.displayName))
                    .toList(),
                onSelect: (item) {
                  setState(() {
                    _selectedProvince = item.value;
                    _selectedRegion = null;
                  });
                },
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: CustomDropdown(
                currentValue: DropdownItem(
                  value: _selectedRegion!,
                  text: _selectedRegion!,
                ),
                options: District.getByProvince(_selectedProvince)
                    .map((item) => DropdownItem<District>(
                        value: item, text: item.displayName))
                    .toList(),
                onSelect: (item) {
                  setState(() {
                    _selectedRegion = item.text;
                  });
                  widget.onChange(item.value);
                },
              ),
            )
          ],
        ),
      ],
    );
  }
}

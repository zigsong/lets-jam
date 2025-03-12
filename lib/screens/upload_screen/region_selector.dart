import 'package:flutter/material.dart';
import 'package:lets_jam/screens/explore_screen/region_helper.dart';
import 'package:lets_jam/widgets/custom_dropdown.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegionItem {
  final String id;
  final String text;

  RegionItem({required this.id, required this.text});
}

class RegionSelector extends StatefulWidget {
  final List<String> selectedRegions;
  final Function(String region) onChange;

  const RegionSelector(
      {super.key, required this.selectedRegions, required this.onChange});

  @override
  State<RegionSelector> createState() => _RegionSelectorState();
}

class _RegionSelectorState extends State<RegionSelector> {
  final supabase = Supabase.instance.client;
  Future<Map<String, List<Map<String, String>>>>? _regionsData;

  late String _selectedCategory;
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _fetchRegions();
  }

  void _fetchRegions() async {
    final data = await supabase.from('regions').select();

    if (data.isNotEmpty) {
      setState(() {
        RegionMap groupedData = groupByCategory(data);
        _regionsData = Future.value(groupByCategory(data));
        _selectedCategory = groupedData.keys.first;
        _selectedRegion =
            groupedData[_selectedCategory]?[0]['subcategory'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: widget.selectedRegions.asMap().entries.map((entry) {
            bool isSelected = widget.selectedRegions.contains(entry.value);

            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.onChange(entry.value);
                    });
                  },
                  child: Tag(
                    text: entry.value,
                    color: TagColorEnum.black,
                    size: TagSizeEnum.small,
                    selected: isSelected,
                  ),
                ),
                if (entry != widget.selectedRegions.asMap().entries.last)
                  const SizedBox(width: 6),
              ],
            );
          }).toList(),
        ),
        FutureBuilder(
          future: _regionsData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(child: Text("지역 목록 불러오기 에러: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No regions available"));
            }

            final regions = snapshot.data!;

            if (_selectedRegion == null && regions[_selectedCategory] != null) {
              _selectedRegion =
                  regions[_selectedCategory]!.first['subcategory'];
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CustomDropdown(
                    currentValue: DropdownItem(
                        id: _selectedCategory, text: _selectedCategory),
                    options: regions.keys
                        .map((el) => DropdownItem(id: el, text: el))
                        .toList(),
                    onSelect: (value) {
                      setState(() {
                        _selectedCategory = value.text;
                        _selectedRegion = null;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                if (regions[_selectedCategory] != null)
                  Expanded(
                    child: CustomDropdown(
                      currentValue: DropdownItem(
                        id: _selectedRegion!,
                        text: _selectedRegion!,
                      ),
                      options: regions[_selectedCategory]!
                          .map((el) => DropdownItem(
                              id: el['subcategory']!, text: el['subcategory']!))
                          .toList(),
                      onSelect: (value) {
                        setState(() {
                          _selectedRegion = value.text;
                        });
                        widget.onChange(value.id);
                      },
                    ),
                  )
              ],
            );
          },
        ),
      ],
    );
  }
}

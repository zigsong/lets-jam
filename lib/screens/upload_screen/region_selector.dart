import 'package:flutter/material.dart';
import 'package:lets_jam/screens/explore_screen/region_helper.dart';
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
                  ),
                ),
                if (entry != widget.selectedRegions.asMap().entries.last)
                  const SizedBox(width: 6),
              ],
            );
          }).toList(),
        ),
        const SizedBox(
          height: 8,
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
                CustomDropdown(
                  value: _selectedCategory,
                  items: regions.keys
                      .map((el) => RegionItem(id: el, text: el))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                      _selectedRegion = null;
                    });
                  },
                ),
                if (regions[_selectedCategory] != null)
                  CustomDropdown(
                    value: _selectedRegion!,
                    items: regions[_selectedCategory]!
                        .map((el) => RegionItem(
                            id: el['subcategory']!, text: el['subcategory']!))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRegion = value!;
                      });
                      widget.onChange(value!);
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String value;
  final List<RegionItem> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item.id,
              child: Text(item.text),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

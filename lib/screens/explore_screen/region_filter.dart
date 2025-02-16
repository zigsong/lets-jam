import 'package:flutter/material.dart';
import 'package:lets_jam/screens/explore_screen/region_helper.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegionFilter extends StatefulWidget {
  const RegionFilter({super.key});

  @override
  State<RegionFilter> createState() => _RegionFilterState();
}

class _RegionFilterState extends State<RegionFilter> {
  final supabase = Supabase.instance.client;
  Future<Map<String, List<String>>>? _regions;
  String? _selectedCategory;
  final List<String> _selectedSubCategories = [];
  final List<String> _selectedRegionIds = [];

  @override
  void initState() {
    super.initState();
    _fetchRegions();
  }

  void _fetchRegions() async {
    final data = await supabase.from('regions').select();

    if (data.isNotEmpty) {
      setState(() {
        _regions = Future.value(groupByCategory(data));
        _selectedCategory = groupByCategory(data).keys.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _regions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text("지역 목록 불러오기 에러: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No regions available"));
          }

          final regions = snapshot.data!;

          return Table(
            border: TableBorder(
              top: BorderSide(
                  width: 0.5, color: ColorSeed.meticulousGrayMedium.color),
              bottom: BorderSide(
                  width: 0.5, color: ColorSeed.meticulousGrayMedium.color),
              verticalInside: BorderSide(
                  width: 0.5, color: ColorSeed.meticulousGrayMedium.color),
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
                      ...regions.keys.map((category) => Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: _selectedCategory == category
                                          ? ColorSeed.organizedBlackMedium.color
                                          : Colors.white),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                          color: _selectedCategory == category
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (regions[_selectedCategory] ?? [])
                            .map((subcategory) => Tag(
                                  text: subcategory,
                                  border: Border.all(
                                    color: ColorSeed.meticulousGrayLight.color,
                                  ),
                                  bgColor: Colors.white,
                                  fgColor: Colors.black,
                                ))
                            .toList()),
                  ),
                ],
              ),
            ],
          );
        });
  }
}

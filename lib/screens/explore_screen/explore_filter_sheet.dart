import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/explore_filter_controller.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/screens/explore_screen/region_filter.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:lets_jam/widgets/wide_button.dart';

class ExploreFilterSheet extends StatefulWidget {
  const ExploreFilterSheet({super.key});

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  final ExploreFilterController exploreFilterController =
      Get.put(ExploreFilterController());

  late Map<FilterEnum, List<String>> tempValues;

  @override
  void initState() {
    super.initState();
    tempValues = exploreFilterController.filterValues;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle =
        const TextStyle(fontSize: 13, fontWeight: FontWeight.w600);

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          )),
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('세션', style: labelStyle),
                      const SizedBox(
                        height: 8,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: SessionEnum.values.map((session) {
                            final sessions =
                                tempValues[FilterEnum.session] ?? [];

                            return Row(
                              children: [
                                Tag(
                                  text: sessionMap[session] ?? '',
                                  color: TagColorEnum.black,
                                  selected: sessions.contains(session.name),
                                  onToggle: () {
                                    setState(() {
                                      if (sessions.contains(session.name)) {
                                        sessions.remove(session.name);
                                      } else {
                                        sessions.add(session.name);
                                      }
                                    });
                                  },
                                ),
                                if (session != SessionEnum.values.last)
                                  const SizedBox(width: 8),
                              ],
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  )),
              Divider(
                height: 10,
                thickness: 0.5,
                color: ColorSeed.boldOrangeMedium.color,
              ),
              Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('레벨', style: labelStyle),
                      const SizedBox(
                        height: 8,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: LevelEnum.values.map((level) {
                            final levels = tempValues[FilterEnum.level] ?? [];

                            return Row(
                              children: [
                                Tag(
                                  text: levelMap[level] ?? '',
                                  color: TagColorEnum.black,
                                  selected: levels.contains(level.name),
                                  onToggle: () {
                                    setState(() {
                                      if (levels.contains(level.name)) {
                                        levels.remove(level.name);
                                      } else {
                                        levels.add(level.name);
                                      }
                                    });
                                  },
                                ),
                                if (level != LevelEnum.values.last)
                                  const SizedBox(width: 8),
                              ],
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  )),
              Divider(
                height: 5,
                thickness: 0.5,
                color: ColorSeed.boldOrangeMedium.color,
              ),
              Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('지역', style: labelStyle),
                      const SizedBox(
                        height: 8,
                      ),
                      RegionFilter(
                        selectedRegionIds: exploreFilterController
                                .filterValues[FilterEnum.region] ??
                            [],
                        toggleRegion: (regionId) {
                          setState(() {
                            final regions = tempValues[FilterEnum.region] ?? [];

                            if (regions.contains(regionId)) {
                              regions.remove(regionId);
                            } else {
                              regions.add(regionId);
                            }
                          });
                        },
                      ),
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.only(
                    top: 5, right: 16, bottom: 10, left: 16),
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 11, horizontal: 25.5),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          for (var key in tempValues.keys) {
                            tempValues[key] = [];
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            '초기화',
                            style: TextStyle(
                                color: ColorSeed.boldOrangeRegular.color,
                                fontSize: 13,
                                height: 1.38),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Image.asset(
                            width: 18,
                            height: 18,
                            'assets/icons/filter_reset.png',
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: WideButton(
                          text: '필터 적용',
                          onPressed: () {
                            for (var key in tempValues.keys) {
                              exploreFilterController.setFilterValue(
                                  key, tempValues[key] ?? []);
                            }
                          }))
                ]),
              )
            ],
          )
        ],
      ),
    );
  }
}

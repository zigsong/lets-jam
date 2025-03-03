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
  const ExploreFilterSheet({super.key, required this.closeFilterSheet});

  final void Function() closeFilterSheet;

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  final ExploreFilterController exploreFilterController =
      Get.put(ExploreFilterController());

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
                  child: Row(
                    children: [
                      Text('세션', style: labelStyle),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Obx(() => Row(
                                children: SessionEnum.values.map((session) {
                                  final sessions =
                                      exploreFilterController.sessions;

                                  return Row(
                                    children: [
                                      Tag(
                                        text: sessionMap[session] ?? '',
                                        color: TagColorEnum.black,
                                        selected: sessions.contains(session),
                                        onToggle: () {
                                          exploreFilterController
                                              .toggleSession(session);
                                        },
                                      ),
                                      if (session != SessionEnum.values.last)
                                        const SizedBox(width: 8),
                                    ],
                                  );
                                }).toList(),
                              )),
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
                  child: Row(
                    children: [
                      Text('레벨', style: labelStyle),
                      const SizedBox(
                        width: 8,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Obx(() => Row(
                              children: LevelEnum.values.map((level) {
                                final levels = exploreFilterController.levels;

                                return Row(
                                  children: [
                                    Tag(
                                      text: levelMap[level] ?? '',
                                      color: TagColorEnum.black,
                                      selected: levels.contains(level),
                                      onToggle: () {
                                        exploreFilterController
                                            .toggleLevel(level);
                                      },
                                    ),
                                    if (level != LevelEnum.values.last)
                                      const SizedBox(width: 8),
                                  ],
                                );
                              }).toList(),
                            )),
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
                      /** TODO: fix - 초기화시 지역 필터가 초기화 안되는... */
                      RegionFilter(
                        selectedRegionIds: exploreFilterController.regions,
                        toggleRegion: (regionId) {
                          exploreFilterController.toggleRegion(regionId);
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
                        exploreFilterController.reset();
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
                            widget.closeFilterSheet();
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/explore_filter_controller.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/screens/explore_screen/region_filter.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:lets_jam/widgets/wide_button.dart';

class ExploreFilterSheet extends StatefulWidget {
  const ExploreFilterSheet(
      {super.key, required this.type, required this.applyFilter});

  final void Function() applyFilter;
  final FilterEnum type;

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  final ExploreFilterController filterController =
      Get.put(ExploreFilterController());

  @override
  Widget build(BuildContext context) {
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
              widget.type == FilterEnum.session
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Obx(() => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: SessionEnum.values.map((session) {
                              final sessions = filterController.tempSessions;

                              return Tag(
                                text: sessionMap[session] ?? '',
                                color: TagColorEnum.black,
                                selected: sessions.contains(session),
                                onToggle: () {
                                  filterController.toggleSession(session);
                                },
                              );
                            }).toList(),
                          )))
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 11, horizontal: 16),
                      child: RegionFilter(
                        selectedRegions: filterController.tempRegions,
                        toggleRegion: (region) {
                          filterController.toggleRegion(region);
                        },
                      )),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, right: 16, bottom: 20, left: 16),
                child: WideButton(
                    text: '필터 적용',
                    onPressed: () {
                      widget.applyFilter();
                    }),
              )
            ],
          )
        ],
      ),
    );
  }
}

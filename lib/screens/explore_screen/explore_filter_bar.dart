import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/explore_filter_controller.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/widgets/tag.dart';

class ExploreFilterBar extends StatefulWidget {
  const ExploreFilterBar({
    super.key,
    required this.selectedPage,
    required this.isFilterSheetOpen,
    required this.onToggleFilter,
  });

  final int selectedPage;
  final bool isFilterSheetOpen;
  final void Function() onToggleFilter;

  @override
  State<ExploreFilterBar> createState() => _ExploreFilterBarState();
}

class _ExploreFilterBarState extends State<ExploreFilterBar> {
  @override
  Widget build(BuildContext context) {
    final ExploreFilterController exploreFilterController =
        Get.put(ExploreFilterController());

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onToggleFilter,
                child: SizedBox(
                    width: 20,
                    child: Image.asset('assets/icons/filter_active.png')),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(() {
                      List<SessionEnum> sessionFilters =
                          exploreFilterController.tempSessions;
                      List<LevelEnum> levelFilters =
                          exploreFilterController.tempLevels;
                      List<String> regionFilters =
                          exploreFilterController.tempRegions;

                      bool isFilterApplied = sessionFilters.isNotEmpty ||
                          levelFilters.isNotEmpty ||
                          regionFilters.isNotEmpty;

                      return Row(
                          children: isFilterApplied
                              ? [
                                  ...sessionFilters.map((session) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Tag(
                                            color: TagColorEnum.orange,
                                            text: sessionMap[session]!,
                                            withXIcon: true,
                                            selected: widget.selectedPage == 1,
                                            onToggle: () {
                                              exploreFilterController
                                                  .toggleSession(session);
                                            }),
                                      )),
                                  ...levelFilters.map((level) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Tag(
                                            color: TagColorEnum.orange,
                                            text: levelMap[level]!,
                                            withXIcon: true,
                                            selected: widget.selectedPage == 1,
                                            onToggle: () {
                                              exploreFilterController
                                                  .toggleLevel(level);
                                            }),
                                      )),
                                  ...regionFilters.map((regionId) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Tag(
                                          color: TagColorEnum.orange,
                                          text: regionId,
                                          withXIcon: true,
                                          selected: widget.selectedPage == 1,
                                          onToggle: () {
                                            exploreFilterController
                                                .toggleRegion(regionId);
                                          },
                                        ),
                                      ))
                                ]
                              : [
                                  const Tag(
                                      text: '필터 전체', color: TagColorEnum.orange)
                                ]);
                    })),
              ),
            ],
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/explore_filter_controller.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
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

  final void Function(FilterEnum filterType) onToggleFilter;

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
              SizedBox(
                  width: 20,
                  child: Image.asset('assets/icons/filter_active.png')),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Obx(() {
                  List<SessionEnum> sessionFilters =
                      exploreFilterController.tempSessions;
                  List<String> regionFilters =
                      exploreFilterController.tempRegions;

                  bool isFilterApplied =
                      sessionFilters.isNotEmpty || regionFilters.isNotEmpty;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                widget.onToggleFilter(FilterEnum.region);
                              },
                              child: const Tag(
                                  text: '지역', color: TagColorEnum.orange)),
                          const SizedBox(
                            width: 12,
                          ),
                          GestureDetector(
                              onTap: () {
                                widget.onToggleFilter(FilterEnum.session);
                              },
                              child: const Tag(
                                  text: '세션', color: TagColorEnum.orange)),
                        ],
                      ),
                      Row(
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
                    ],
                  );
                }),
              ),
            ],
          ),
        )
      ],
    );
  }
}

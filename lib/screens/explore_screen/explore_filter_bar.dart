import 'package:flutter/material.dart';
import 'package:lets_jam/widgets/tag.dart';

class ExploreFilterBar extends StatefulWidget {
  const ExploreFilterBar({
    super.key,
    required this.isFilterSheetOpen,
    required this.onToggleFilter,
  });

  final bool isFilterSheetOpen;
  final void Function() onToggleFilter;

  @override
  State<ExploreFilterBar> createState() => _ExploreFilterBarState();
}

class _ExploreFilterBarState extends State<ExploreFilterBar> {
  @override
  Widget build(BuildContext context) {
    var mockFilteredTags = ['태그1', '태그22', '태그333'];

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
                    child: Row(
                      children: List.generate(mockFilteredTags.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Tag(
                            color: TagColorEnum.orange,
                            text: mockFilteredTags[index],
                            withXIcon: true,
                            // selected: ,
                            // onToggle: ,
                          ),
                        );
                      }),
                    )),
              ),
            ],
          ),
        )
      ],
    );
  }
}

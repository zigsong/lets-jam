import 'package:flutter/material.dart';
import 'package:lets_jam/widgets/filter_tag.dart';

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

class _ExploreFilterBarState extends State<ExploreFilterBar>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Offset>? _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0), // 위에서 시작
      end: const Offset(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));
  }

  void _toggleExploreFilter() {
    print('_toggleExploreFilter');
    if (widget.isFilterSheetOpen) {
      _controller!.reverse();
    } else {
      _controller!.forward();
    }
    setState(() {
      widget.onToggleFilter();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

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
                onTap: _toggleExploreFilter,
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
                          child: FilterTag(text: mockFilteredTags[index]),
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

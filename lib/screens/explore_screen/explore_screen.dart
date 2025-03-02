import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/explore_filter_controller.dart';
import 'package:lets_jam/screens/explore_screen/explore_filter_bar.dart';
import 'package:lets_jam/screens/explore_screen/explore_filter_sheet.dart';
import 'package:lets_jam/screens/explore_screen/explore_posts.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/page_toggler.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageViewController = PageController();
  int _selectedPage = 0;

  final ExploreFilterController exploreFilterController =
      Get.put(ExploreFilterController());

  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isFilterSheetOpen = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  void _slidePage() {
    setState(() {
      _selectedPage = _selectedPage == 0 ? 1 : 0;
    });

    _pageViewController.animateToPage(
      _selectedPage,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  void _toggleExploreFilter() {
    if (_animation.status != AnimationStatus.completed) {
      _controller.forward();
    } else {
      _controller.animateBack(0, duration: const Duration(milliseconds: 300));
    }

    setState(() {
      _isFilterSheetOpen = !_isFilterSheetOpen;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isBandTabSelected = _selectedPage == 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      /** 상태바 아이콘 색상 */
      value: !isBandTabSelected
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Column(
        children: [
          Container(
              height: 102,
              decoration: BoxDecoration(
                  color: isBandTabSelected
                      ? ColorSeed.boldOrangeStrong.color
                      : Colors.transparent),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          width: 25,
                          height: 30,
                          child: isBandTabSelected
                              ? Image.asset('assets/images/logo_sm_white.png')
                              : Image.asset(
                                  'assets/images/logo_sm_orange.png')),
                      PageToggler(
                        selectedIndex: _selectedPage,
                        onTap: _slidePage,
                      ),
                      SizedBox(
                          width: 28,
                          height: 28,
                          child: isBandTabSelected
                              ? Image.asset('assets/icons/bell_white.png')
                              : Image.asset('assets/icons/bell_active.png')),
                    ],
                  ),
                ),
              )),
          // 포스팅 필터 및 선택된 태그
          ExploreFilterBar(
            isFilterSheetOpen: _isFilterSheetOpen,
            onToggleFilter: _toggleExploreFilter,
          ),
          // 포스팅 목록
          Expanded(
            child: Stack(children: [
              ExplorePosts(pageController: _pageViewController),
              // dimmed 배경
              if (_isFilterSheetOpen)
                GestureDetector(
                  onTap: _toggleExploreFilter,
                  child: AnimatedOpacity(
                    opacity: _isFilterSheetOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      color: Colors.grey,
                    ),
                  ),
                ),
              if (_isFilterSheetOpen)
                SizeTransition(
                    sizeFactor: _animation,
                    axis: Axis.vertical,
                    child: const ExploreFilterSheet()),
            ]),
          )
        ],
      ),
    );
  }
}

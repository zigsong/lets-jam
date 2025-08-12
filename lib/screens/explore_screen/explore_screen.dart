import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/explore_filter_controller.dart';
import 'package:lets_jam/main.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/alarm_screen.dart';
import 'package:lets_jam/screens/explore_screen/explore_filter_bar.dart';
import 'package:lets_jam/screens/explore_screen/explore_filter_sheet.dart';
import 'package:lets_jam/screens/explore_screen/explore_posts.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  final PageController _pageViewController = PageController();
  int _selectedPage = 0;

  final ExploreFilterController exploreFilterController =
      Get.put(ExploreFilterController());

  late void Function() _reloadItems;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _controller.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // 다른 화면에서 돌아왔을 때 호출됨
    _reloadItems();
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

  void _applyFilter() {
    exploreFilterController.applyFilters();

    _controller.animateBack(0, duration: const Duration(milliseconds: 300));
    setState(() {
      _isFilterSheetOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var isBandTabSelected = _selectedPage == 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      /** 상태바 아이콘 색상 */
      value: !isBandTabSelected
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Column(
          children: [
            Container(
                height: 82,
                decoration: BoxDecoration(
                    color: isBandTabSelected
                        ? ColorSeed.boldOrangeStrong.color
                        : Colors.transparent),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 28, height: 28, child: Text('')),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const AlarmScreen()),
                            );
                          },
                          child: SizedBox(
                              width: 28,
                              height: 28,
                              child: isBandTabSelected
                                  ? Image.asset('assets/icons/bell_white.png')
                                  : Image.asset(
                                      'assets/icons/bell_active.png')),
                        ),
                      ],
                    ),
                  ),
                )),
            TabBar(
              labelColor: ColorSeed.boldOrangeMedium.color,
              unselectedLabelColor: ColorSeed.meticulousGrayMedium.color,
              indicatorColor: ColorSeed.boldOrangeMedium.color,
              indicatorWeight: 2.0,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(
                  child: Text(
                    '멤버 구하기',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Tab(
                  child: Text(
                    '밴드 찾기',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            // 포스팅 필터 및 선택된 태그
            ExploreFilterBar(
              selectedPage: _selectedPage,
              isFilterSheetOpen: _isFilterSheetOpen,
              onToggleFilter: _toggleExploreFilter,
            ),
            // 포스팅 목록
            Expanded(
              child: Stack(
                children: [
                  TabBarView(
                    children: [
                      ExplorePosts(
                        postType: PostTypeEnum.findMember,
                        onReloadRegister: (reloadFn) {
                          _reloadItems = reloadFn;
                        },
                      ),
                      ExplorePosts(
                        postType: PostTypeEnum.findBand,
                        onReloadRegister: (reloadFn) {
                          _reloadItems = reloadFn;
                        },
                      ),
                    ],
                  ),
                  // dimmed 배경
                  // TODO: 필터 UI 수정하면서 구조 같이 수정하기
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
                        child: ExploreFilterSheet(
                          applyFilter: _applyFilter,
                        )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

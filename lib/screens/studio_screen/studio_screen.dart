import 'package:flutter/material.dart';
import 'package:lets_jam/models/region_enum.dart';
import 'package:lets_jam/widgets/notification_bell.dart';
import 'package:lets_jam/screens/settings_screen/settings_screen.dart';
import 'package:lets_jam/screens/studio_screen/studio.dart';
import 'package:lets_jam/screens/studio_screen/studio_card.dart';
import 'package:lets_jam/screens/studio_screen/studio_like_service.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:lets_jam/widgets/wide_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen>
    with SingleTickerProviderStateMixin {
  // 적용된 지역 필터 (비어있으면 전체)
  final Set<District> _selectedDistricts = {};

  // 필터 시트가 열려있는 동안의 임시 선택 (필터 적용 버튼으로 확정)
  final Set<District> _tempDistricts = {};

  // 필터 시트에서 현재 보고 있는 시/도
  Province _selectedProvince = Province.values.first;

  // 필터 시트 열림 상태
  bool _isFilterOpen = false;

  late final AnimationController _sheetController;
  late final Animation<double> _sheetAnimation;

  // 찜한 합주실 id 집합 (studio_likes 테이블과 동기화)
  final Set<String> _likedRooms = {};

  // Supabase에서 불러온 합주실 목록
  List<Studio> _studios = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sheetAnimation = CurvedAnimation(
      parent: _sheetController,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    _load();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res = await Supabase.instance.client
          .from('studios')
          .select('id, studio_name, region, rooms, studio_photos')
          .order('studio_name');
      final list = (res as List)
          .map((e) => Studio.fromMap(e as Map<String, dynamic>))
          .toList();
      final likedIds = await StudioLikeService.fetchLikedIds();
      if (!mounted) return;
      setState(() {
        _studios = list;
        _likedRooms
          ..clear()
          ..addAll(likedIds);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '합주실을 불러오지 못했어요';
        _loading = false;
      });
    }
  }

  // "전체"(isAll) 선택은 해당 시/도의 구체 지역들로 확장해서 필터링
  Set<District> get _expandedDistricts {
    final result = <District>{};
    for (final d in _selectedDistricts) {
      if (d.isAll) {
        result.addAll(District.getSpecificByProvince(d.province));
      } else {
        result.add(d);
      }
    }
    return result;
  }

  List<Studio> get _filteredRooms {
    final expanded = _expandedDistricts;
    if (expanded.isEmpty) return _studios;
    return _studios
        .where(
            (room) => room.district != null && expanded.contains(room.district))
        .toList();
  }

  bool _provinceHasSelection(Province province) =>
      _selectedDistricts.any((d) => d.province == province);

  void _onProvinceTap(Province province) {
    if (!_isFilterOpen) {
      _openSheet(province);
    } else if (_selectedProvince != province) {
      setState(() => _selectedProvince = province);
    } else {
      _closeSheet();
    }
  }

  void _openSheet(Province province) {
    setState(() {
      _selectedProvince = province;
      _isFilterOpen = true;
      _tempDistricts
        ..clear()
        ..addAll(_selectedDistricts);
    });
    _sheetController.forward();
  }

  void _closeSheet() {
    _sheetController.animateBack(0,
        duration: const Duration(milliseconds: 300));
    setState(() => _isFilterOpen = false);
  }

  // 시트 내 구 토글 (explore와 동일한 "전체" 상호배타 로직)
  void _toggleTempDistrict(District district) {
    setState(() {
      final isAdding = !_tempDistricts.contains(district);
      if (isAdding) {
        _tempDistricts.add(district);
        if (district.isAll) {
          _tempDistricts
              .removeWhere((d) => d.province == district.province && !d.isAll);
        } else {
          _tempDistricts
              .removeWhere((d) => d.province == district.province && d.isAll);
        }
      } else {
        _tempDistricts.remove(district);
      }
    });
  }

  void _applyFilter() {
    _sheetController.animateBack(0,
        duration: const Duration(milliseconds: 300));
    setState(() {
      _selectedDistricts
        ..clear()
        ..addAll(_tempDistricts);
      _isFilterOpen = false;
    });
  }

  void _reset() {
    setState(() {
      _selectedDistricts.clear();
      _tempDistricts.clear();
    });
  }

  Future<void> _toggleLike(Studio room) async {
    final wasLiked = _likedRooms.contains(room.id);

    // 낙관적 업데이트: 먼저 UI 반영 후 실패하면 롤백
    setState(() {
      if (wasLiked) {
        _likedRooms.remove(room.id);
      } else {
        _likedRooms.add(room.id);
      }
    });

    try {
      if (wasLiked) {
        await StudioLikeService.unlike(room.id);
      } else {
        await StudioLikeService.like(room.id);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (wasLiked) {
          _likedRooms.add(room.id);
        } else {
          _likedRooms.remove(room.id);
        }
      });
    }
  }

  Widget _buildBody(List<Studio> rooms) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _load();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }
    if (rooms.isEmpty) {
      return const Center(
        child: Text(
          '조건에 맞는 합주실이 없어요',
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return StudioCard(
          room: room,
          liked: _likedRooms.contains(room.id),
          onToggleLike: () => _toggleLike(room),
        );
      },
    );
  }

  // 시/도 pill + 초기화 버튼이 있는 필터 바
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
              width: 20, child: Image.asset('assets/icons/filter_active.png')),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    for (final province in Province.values) ...[
                      Tag(
                        text: province.displayName,
                        color: TagColorEnum.orange,
                        selected:
                            (_isFilterOpen && _selectedProvince == province) ||
                                _provinceHasSelection(province),
                        onToggle: () => _onProvinceTap(province),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
                GestureDetector(
                  onTap: _reset,
                  child: Row(
                    children: [
                      Text(
                        '초기화',
                        style: TextStyle(
                          color: ColorSeed.boldOrangeRegular.color,
                          fontSize: 13,
                          height: 1.38,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Image.asset('assets/icons/filter_reset.png',
                          width: 18, height: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 아래로 펼쳐지는 지역(구) 선택 시트
  Widget _buildFilterSheet() {
    final districts = District.getByProvince(_selectedProvince);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: districts
                      .map((district) => Tag(
                            text: district.displayName,
                            color: TagColorEnum.black,
                            selected: _tempDistricts.contains(district),
                            onToggle: () => _toggleTempDistrict(district),
                          ))
                      .toList(),
                ),
              ),
              Divider(height: 0.5, color: ColorSeed.boldOrangeLight.color),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, right: 16, bottom: 20, left: 16),
                child: WideButton(
                    text: '필터 적용',
                    showShadow: false,
                    onPressed: _applyFilter),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = _filteredRooms;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '합주실',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ColorSeed.boldOrangeStrong.color),
                ),
                Row(
                  children: [
                    const NotificationBell(),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: SizedBox(
                            width: 28,
                            height: 28,
                            child: Image.asset('assets/icons/settings.png')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 지역 필터 바 (시/도 선택)
          _buildFilterBar(),
          // 목록 + 필터 시트 오버레이
          Expanded(
            child: Stack(
              children: [
                _buildBody(rooms),
                // dimmed 배경
                if (_isFilterOpen)
                  GestureDetector(
                    onTap: _closeSheet,
                    child: AnimatedOpacity(
                      opacity: _isFilterOpen ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(color: Colors.grey),
                    ),
                  ),
                if (_isFilterOpen)
                  SizeTransition(
                    sizeFactor: _sheetAnimation,
                    axis: Axis.vertical,
                    child: _buildFilterSheet(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

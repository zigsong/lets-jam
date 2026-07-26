import 'package:flutter/material.dart';
import 'package:lets_jam/models/region_enum.dart';
import 'package:lets_jam/screens/alarm_screen.dart';
import 'package:lets_jam/screens/settings_screen/settings_screen.dart';
import 'package:lets_jam/screens/studio_screen/studio.dart';
import 'package:lets_jam/screens/studio_screen/studio_card.dart';
import 'package:lets_jam/screens/studio_screen/studio_like_service.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/tag.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  // 선택된 지역 필터 (비어있으면 전체)
  final Set<District> _selectedDistricts = {};

  // 찜한 합주실 id 집합 (studio_likes 테이블과 동기화)
  final Set<String> _likedRooms = {};

  // Supabase에서 불러온 합주실 목록
  List<Studio> _studios = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Supabase.instance.client
          .from('studios')
          .select('id, studio_name, region, rooms')
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

  // 필터 칩으로 노출할 지역들 (전체 옵션 제외)
  List<District> get _regionOptions =>
      District.values.where((d) => !d.isAll).toList();

  List<Studio> get _filteredRooms {
    if (_selectedDistricts.isEmpty) return _studios;
    return _studios
        .where((room) =>
            room.district != null &&
            _selectedDistricts.contains(room.district))
        .toList();
  }

  void _toggleDistrict(District district) {
    setState(() {
      if (_selectedDistricts.contains(district)) {
        _selectedDistricts.remove(district);
      } else {
        _selectedDistricts.add(district);
      }
    });
  }

  void _reset() {
    setState(() => _selectedDistricts.clear());
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

  @override
  Widget build(BuildContext context) {
    final rooms = _filteredRooms;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '합주실',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ColorSeed.boldOrangeMedium.color),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const AlarmScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: SizedBox(
                            width: 28,
                            height: 28,
                            child: Image.asset('assets/icons/bell_orange.png')),
                      ),
                    ),
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
          // 지역 필터 바 (오른쪽에 초기화 버튼)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final district in _regionOptions) ...[
                          Tag(
                            text: district.displayName,
                            color: TagColorEnum.black,
                            size: TagSizeEnum.small,
                            selected: _selectedDistricts.contains(district),
                            onToggle: () => _toggleDistrict(district),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_selectedDistricts.isNotEmpty)
                  GestureDetector(
                    onTap: _reset,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                      child: Row(
                        children: [
                          Text(
                            '초기화',
                            style: TextStyle(
                              color: ColorSeed.boldOrangeRegular.color,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Image.asset('assets/icons/filter_reset.png',
                              width: 18, height: 18),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 목록
          Expanded(child: _buildBody(rooms)),
        ],
      ),
    );
  }
}

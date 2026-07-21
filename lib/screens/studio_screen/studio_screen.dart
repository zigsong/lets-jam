import 'package:flutter/material.dart';
import 'package:lets_jam/models/region_enum.dart';
import 'package:lets_jam/screens/alarm_screen.dart';
import 'package:lets_jam/screens/settings_screen/settings_screen.dart';
import 'package:lets_jam/screens/studio_screen/studio.dart';
import 'package:lets_jam/screens/studio_screen/studio_card.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/tag.dart';

/// [프로토타입] 하드코딩된 합주실 목록.
const List<Studio> _mockRooms = [
  Studio(
    name: '홍대 사운드박스 합주실',
    district: District.hongdae,
    pricePerHour: 15000,
    capacity: 6,
    rating: 4.8,
    reviewCount: 132,
    tags: ['드럼 완비', '앰프 대여', '주차가능'],
  ),
  Studio(
    name: '강남 리듬스테이지',
    district: District.gangnam,
    pricePerHour: 22000,
    capacity: 8,
    rating: 4.6,
    reviewCount: 87,
    tags: ['방음 우수', '녹음 가능', '심야 이용'],
  ),
  Studio(
    name: '건대 그루브룸',
    district: District.kondae,
    pricePerHour: 12000,
    capacity: 5,
    rating: 4.9,
    reviewCount: 210,
    tags: ['가성비', '드럼 완비', '24시간'],
  ),
  Studio(
    name: '잠실 재밍하우스',
    district: District.jamsil,
    pricePerHour: 18000,
    capacity: 7,
    rating: 4.3,
    reviewCount: 54,
    tags: ['넓은 공간', '주차가능'],
  ),
  Studio(
    name: '영등포 튠업스튜디오',
    district: District.yeondeungpo,
    pricePerHour: 16000,
    capacity: 6,
    rating: 4.5,
    reviewCount: 76,
    tags: ['신축', '앰프 대여', '음료 무료'],
  ),
  Studio(
    name: '종로 멜로디베이스',
    district: District.jongno,
    pricePerHour: 14000,
    capacity: 5,
    rating: 4.2,
    reviewCount: 41,
    tags: ['접근성 좋음', '드럼 완비'],
  ),
  Studio(
    name: '수원 하모니큐브',
    district: District.suwon,
    pricePerHour: 11000,
    capacity: 6,
    rating: 4.7,
    reviewCount: 98,
    tags: ['가성비', '주차가능', '심야 이용'],
  ),
  Studio(
    name: '인천 비트팩토리',
    district: District.incheon,
    pricePerHour: 13000,
    capacity: 8,
    rating: 4.4,
    reviewCount: 63,
    tags: ['넓은 공간', '녹음 가능'],
  ),
];

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  // 선택된 지역 필터 (비어있으면 전체)
  final Set<District> _selectedDistricts = {};

  // [프로토타입] 찜한 합주실 (이름 기준, 로컬 상태로만 유지)
  final Set<String> _likedRooms = {};

  // 필터 칩으로 노출할 지역들 (전체 옵션 제외)
  List<District> get _regionOptions =>
      District.values.where((d) => !d.isAll).toList();

  List<Studio> get _filteredRooms {
    if (_selectedDistricts.isEmpty) return _mockRooms;
    return _mockRooms
        .where((room) => _selectedDistricts.contains(room.district))
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

  void _toggleLike(Studio room) {
    setState(() {
      if (_likedRooms.contains(room.name)) {
        _likedRooms.remove(room.name);
      } else {
        _likedRooms.add(room.name);
      }
    });
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
          // 지역 필터 바
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
              ],
            ),
          ),
          // 선택 요약 + 초기화
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_selectedDistricts.isNotEmpty)
                  GestureDetector(
                    onTap: _reset,
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
              ],
            ),
          ),
          // 목록
          Expanded(
            child: rooms.isEmpty
                ? const Center(
                    child: Text(
                      '조건에 맞는 합주실이 없어요',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        liked: _likedRooms.contains(room.name),
                        onToggleLike: () => _toggleLike(room),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

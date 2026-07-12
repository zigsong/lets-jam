import 'package:flutter/material.dart';
import 'package:lets_jam/models/region_enum.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/post_badge.dart';
import 'package:lets_jam/widgets/tag.dart';

/// [프로토타입] 합주실 예약 도메인 임시 모델.
/// 실제 백엔드(Supabase) 연동 전까지 목데이터로만 동작한다.
class Studio {
  final String name;
  final District district;
  final int pricePerHour; // 시간당 요금(원)
  final int capacity; // 최대 수용 인원
  final double rating;
  final int reviewCount;
  final List<String> tags; // 편의시설/특징
  final bool available; // 예약 가능 여부

  const Studio({
    required this.name,
    required this.district,
    required this.pricePerHour,
    required this.capacity,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    this.available = true,
  });
}

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
    available: false,
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
                const Text(
                  '합주실',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ColorSeed.boldOrangeLight.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '프로토타입',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ColorSeed.boldOrangeStrong.color,
                    ),
                  ),
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
                Image.asset('assets/icons/filter_active.png', width: 20),
                const SizedBox(width: 8),
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
                Text(
                  '합주실 ${rooms.length}곳',
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorSeed.organizedBlackLight.color,
                  ),
                ),
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
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: rooms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _StudioCard(room: rooms[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StudioCard extends StatelessWidget {
  final Studio room;

  const _StudioCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // [프로토타입] 상세 화면은 아직 미구현
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${room.name} 상세는 준비 중이에요'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(width: 1, color: ColorSeed.boldOrangeRegular.color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 좌측 정보
              Expanded(
                flex: 7,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (!room.available)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: ColorSeed.meticulousGrayLight.color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '예약마감',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ColorSeed.organizedBlackLight.color,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          PostBadge(text: room.district.displayName),
                          PostBadge(text: '${room.capacity}인'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        room.tags.join('  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorSeed.organizedBlackLight.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: Color(0xffFFC02D)),
                          const SizedBox(width: 2),
                          Text(
                            '${room.rating} (${room.reviewCount})',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // 우측 가격
              Container(
                width: 96,
                decoration: BoxDecoration(
                  color: ColorSeed.boldOrangeLight.color,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(room.pricePerHour / 1000).toStringAsFixed(0)}천원',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ColorSeed.boldOrangeStrong.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '시간당',
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorSeed.organizedBlackLight.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

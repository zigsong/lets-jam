import 'package:lets_jam/models/region_enum.dart';

/// Supabase `studios` 테이블 한 행.
/// 현재 합주실 카드 UI에서 실제로 그리는 필드만 담는다.
class Studio {
  final String id;
  final String name;

  /// 표시용 지역 라벨 (DB `region` 원문). null 가능.
  final String? regionLabel;

  /// 필터용 지역. region 문자열이 [District.displayName]과 일치할 때만 채워진다.
  final District? district;

  /// 룸 개수 (rooms 배열 길이).
  final int roomCount;

  /// 룸들 중 최저 가격(원). 가격 정보가 하나도 없으면 null.
  final int? minPrice;

  const Studio({
    required this.id,
    required this.name,
    required this.regionLabel,
    required this.district,
    required this.roomCount,
    required this.minPrice,
  });

  factory Studio.fromMap(Map<String, dynamic> map) {
    final region = (map['region'] as String?)?.trim();
    final rooms = (map['rooms'] as List?) ?? const [];

    final prices = rooms
        .whereType<Map>()
        .map((room) => room['price'])
        .whereType<num>()
        .map((price) => price.toInt())
        .toList();

    return Studio(
      id: map['id'] as String,
      name: (map['studio_name'] as String?)?.trim() ?? '',
      regionLabel: (region == null || region.isEmpty) ? null : region,
      district: region == null ? null : _byLabel[region],
      roomCount: rooms.length,
      minPrice: prices.isEmpty ? null : prices.reduce((a, b) => a < b ? a : b),
    );
  }

  /// displayName -> District 역방향 조회 테이블.
  static final Map<String, District> _byLabel = {
    for (final d in District.values) d.displayName: d,
  };
}

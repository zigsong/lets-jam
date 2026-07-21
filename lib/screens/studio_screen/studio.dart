import 'package:lets_jam/models/region_enum.dart';

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
  final String? imagePath; // null이면 준비중 플레이스홀더 노출

  const Studio({
    required this.name,
    required this.district,
    required this.pricePerHour,
    required this.capacity,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    this.imagePath,
  });
}

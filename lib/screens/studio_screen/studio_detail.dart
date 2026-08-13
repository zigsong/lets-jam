/// 합주실 상세 화면에서 쓰는 전체 데이터.
/// 목록용 [Studio]와 달리 주소·연락처·예약수단·룸 상세까지 담는다.
class StudioDetail {
  final String id;
  final String name;

  /// 표시용 지역 라벨 (DB `region` 원문). null 가능.
  final String? regionLabel;

  /// 주소 (DB `address`).
  final String? address;

  /// 전화번호 (DB `studio_phone`).
  final String? phone;

  /// 예약/문의 수단 (DB `reservation_method`, 예: "네이버예약").
  final String? reservationMethod;

  /// 예약/문의 링크 (DB `reservation_method_link`).
  final String? reservationLink;

  /// 대표 사진 (DB `studio_photo`). null이면 플레이스홀더 노출.
  final String? photo;

  /// 룸 목록.
  final List<StudioRoom> rooms;

  const StudioDetail({
    required this.id,
    required this.name,
    required this.regionLabel,
    required this.address,
    required this.phone,
    required this.reservationMethod,
    required this.reservationLink,
    required this.photo,
    required this.rooms,
  });

  factory StudioDetail.fromMap(Map<String, dynamic> map) {
    final region = (map['region'] as String?)?.trim();
    final rooms = (map['rooms'] as List?) ?? const [];

    return StudioDetail(
      id: map['id'] as String,
      name: (map['studio_name'] as String?)?.trim() ?? '',
      regionLabel: (region == null || region.isEmpty) ? null : region,
      address: _nonEmpty(map['address'] as String?),
      phone: _nonEmpty(map['studio_phone'] as String?),
      reservationMethod: _nonEmpty(map['reservation_method'] as String?),
      reservationLink: _nonEmpty(map['reservation_method_link'] as String?),
      photo: _nonEmpty(map['studio_photo'] as String?),
      rooms: rooms
          .whereType<Map>()
          .map((e) => StudioRoom.fromMap(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  static String? _nonEmpty(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}

/// 합주실 룸 하나.
class StudioRoom {
  final String name;

  /// 1시간당 가격(원). null 가능.
  final int? price;

  /// 정원. null 가능.
  final int? capacity;

  /// 최대 인원. null 가능.
  final int? maxCapacity;

  /// 장비 목록.
  final List<RoomEquipment> equipments;

  const StudioRoom({
    required this.name,
    required this.price,
    required this.capacity,
    required this.maxCapacity,
    required this.equipments,
  });

  factory StudioRoom.fromMap(Map<String, dynamic> map) {
    final equipments = (map['equipments'] as List?) ?? const [];

    return StudioRoom(
      name: (map['name'] as String?)?.trim() ?? '',
      price: (map['price'] as num?)?.toInt(),
      capacity: (map['capacity'] as num?)?.toInt(),
      maxCapacity: (map['max_capacity'] as num?)?.toInt(),
      equipments: equipments
          .whereType<Map>()
          .map((e) => RoomEquipment.fromMap(e.cast<String, dynamic>()))
          .where((e) => e.type.isNotEmpty || e.models.isNotEmpty)
          .toList(),
    );
  }
}

/// 룸 장비 한 종류 (예: 드럼 - [모델1, 모델2]).
class RoomEquipment {
  final String type;
  final List<String> models;

  const RoomEquipment({required this.type, required this.models});

  factory RoomEquipment.fromMap(Map<String, dynamic> map) {
    final models = (map['models'] as List?) ?? const [];
    return RoomEquipment(
      type: (map['type'] as String?)?.trim() ?? '',
      models: models
          .whereType<String>()
          .map((m) => m.trim())
          .where((m) => m.isNotEmpty)
          .toList(),
    );
  }

  /// "드럼 - DW콜렉터, dw9000페달" 형태의 한 줄 표기.
  String get displayLine {
    if (models.isEmpty) return type;
    final joined = models.join(', ');
    return type.isEmpty ? joined : '$type - $joined';
  }
}

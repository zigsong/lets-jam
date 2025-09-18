// 대분류 (시/도)
enum Province {
  seoul('서울'),
  gyeonggiIncheon('경기/인천');

  const Province(this.displayName);
  final String displayName;
}

// 소분류 (구/동)
enum District {
  // 서울 - 전체 옵션
  seoulAll('서울 전체', Province.seoul),
  // 서울 - 세부 지역
  gangnam('강남/서초', Province.seoul),
  jamsil('잠실/송파/강동', Province.seoul),
  yeondeungpo('영등포/여의도/강서', Province.seoul),
  kondae('건대/성수/왕십리', Province.seoul),
  jongno('종로/중구', Province.seoul),
  hongdae('홍대/합정/마포', Province.seoul),
  yongsan('용산/이태원/한남', Province.seoul),
  seongbuk('성북/노원/중랑', Province.seoul),
  kuro('구로/관악/동작', Province.seoul),

  // 경기/인천 - 전체 옵션
  gyeonggiIncheonAll('경기/인천 전체', Province.gyeonggiIncheon),
  // 경기/인천
  northGyeonggi('경기 북부', Province.gyeonggiIncheon),
  uiwang('의왕/안양/군포', Province.gyeonggiIncheon),
  yongin('용인/화성/평택', Province.gyeonggiIncheon),
  bucheon('부천/시흥/안산', Province.gyeonggiIncheon),
  seongnam('성남/하남', Province.gyeonggiIncheon),
  suwon('수원', Province.gyeonggiIncheon),
  incheon('인천', Province.gyeonggiIncheon);

  const District(this.displayName, this.province);
  final String displayName;
  final Province province;

  // "전체" 옵션인지 확인
  bool get isAll => name.endsWith('All');

  // 특정 Province의 District들 가져오기
  static List<District> getByProvince(Province province) {
    return District.values.where((d) => d.province == province).toList();
  }

  // "전체"가 아닌 구체적 지역들만
  static List<District> getSpecificByProvince(Province province) {
    return District.values
        .where((d) => d.province == province && !d.isAll)
        .toList();
  }
}

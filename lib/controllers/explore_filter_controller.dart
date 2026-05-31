import 'package:get/get.dart';
import 'package:lets_jam/models/region_enum.dart';
import 'package:lets_jam/models/session_enum.dart';

enum FilterEnum { session, region }

class ExploreFilterController extends GetxController {
  var sessions = <SessionEnum>[].obs;
  var regions = <District>[].obs;

  // 태그 선택 시 임시 필터
  var tempSessions = <SessionEnum>[].obs;
  var tempRegions = <District>[].obs;

  void toggleSession(SessionEnum session) {
    if (tempSessions.contains(session)) {
      tempSessions.remove(session);
    } else {
      tempSessions.add(session);
    }
  }

  void toggleRegion(District district) {
    final isAdding = !tempRegions.contains(district);
    if (isAdding) {
      tempRegions.add(district);
      if (district.isAll) {
        final siblings =
            District.getByProvince(district.province).where((d) => !d.isAll);
        tempRegions.removeWhere(siblings.contains);
      } else {
        final allOption = District.getByProvince(district.province)
            .firstWhere((d) => d.isAll);
        tempRegions.remove(allOption);
      }
    } else {
      tempRegions.remove(district);
    }
  }

  // 필터 적용 (버튼 클릭 시 호출)
  void applyFilters(FilterEnum filter) {
    if (filter == FilterEnum.session) {
      sessions.assignAll(tempSessions);
    } else if (filter == FilterEnum.region) {
      regions.assignAll(tempRegions);
    }
  }

  List<District> getExpandedRegions() {
    List<District> expandedRegions = [];

    for (District district in regions) {
      if (district.isAll) {
        // "전체" 옵션이면 해당 Province의 모든 District 추가
        expandedRegions.addAll(District.getByProvince(district.province));
      } else {
        // 개별 지역이면 그대로 추가
        expandedRegions.add(district);
      }
    }

    return expandedRegions.toSet().toList(); // 중복 제거
  }

  void resetTemps(FilterEnum filter) {
    if (filter == FilterEnum.session) {
      tempSessions.assignAll(sessions);
    } else if (filter == FilterEnum.region) {
      tempRegions.assignAll(regions);
    }
  }

  void reset() {
    sessions.clear();
    regions.clear();
    tempSessions.clear();
    tempRegions.clear();
  }
}

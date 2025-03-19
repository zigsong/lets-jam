import 'package:get/get.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';

enum FilterEnum { session, level, region }

class ExploreFilterController extends GetxController {
  var sessions = <SessionEnum>[].obs;
  var levels = <LevelEnum>[].obs;
  var regions = <String>[].obs;

  // 태그 선택 시 임시 필터
  var tempSessions = <SessionEnum>[].obs;
  var tempLevels = <LevelEnum>[].obs;
  var tempRegions = <String>[].obs;

  void toggleSession(SessionEnum session) {
    if (tempSessions.contains(session)) {
      tempSessions.remove(session);
      sessions.remove(session);
    } else {
      tempSessions.add(session);
    }
  }

  void toggleLevel(LevelEnum level) {
    if (tempLevels.contains(level)) {
      tempLevels.remove(level);
      levels.remove(level);
    } else {
      tempLevels.add(level);
    }
  }

  void toggleRegion(String regionId) {
    if (tempRegions.contains(regionId)) {
      tempRegions.remove(regionId);
      regions.remove(regionId);
    } else {
      tempRegions.add(regionId);
    }
  }

  // 필터 적용 (버튼 클릭 시 호출)
  void applyFilters() {
    sessions.assignAll(tempSessions);
    levels.assignAll(tempLevels);
    regions.assignAll(tempRegions);
  }

  void reset() {
    sessions.clear();
    levels.clear();
    regions.clear();
  }
}

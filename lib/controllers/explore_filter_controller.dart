import 'package:get/get.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';

enum FilterEnum { session, level, region }

class ExploreFilterController extends GetxController {
  var sessions = <SessionEnum>[].obs;
  var levels = <LevelEnum>[].obs;
  var regions = <String>[].obs;

  void toggleSession(SessionEnum session) {
    if (sessions.contains(session)) {
      sessions.remove(session);
    } else {
      sessions.add(session);
    }
  }

  void toggleLevel(LevelEnum level) {
    if (levels.contains(level)) {
      levels.remove(level);
    } else {
      levels.add(level);
    }
  }

  void toggleRegion(String regionId) {
    if (regions.contains(regionId)) {
      regions.remove(regionId);
    } else {
      regions.add(regionId);
    }
  }

  void reset() {
    sessions.clear();
    levels.clear();
    regions.clear();
  }
}

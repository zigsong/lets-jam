import 'package:get/get.dart';

enum FilterEnum { session, level, region }

class ExploreFilterController extends GetxController {
  Map<FilterEnum, List<String>> filterValues = {
    FilterEnum.session: [],
    FilterEnum.level: [],
    FilterEnum.region: [],
  };

  void setFilterValue(FilterEnum key, List<String> value) {
    filterValues[key] = List.from(value);
  }
}

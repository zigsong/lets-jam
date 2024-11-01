import 'package:lets_jam/models/level_enum.dart';

/// MARK: FindBandModel을 따로 만들어야 할까?
class FindSessionModel {
  String title;
  List<LevelEnum> levels;

  FindSessionModel.init()
      : title = '',
        levels = [];
}

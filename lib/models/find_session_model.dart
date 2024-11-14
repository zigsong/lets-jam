import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';

/// MARK: FindBandModel을 따로 만들어야 할까?
class FindSessionModel {
  String title;
  List<LevelEnum> levels;
  List<SessionEnum> sessions;
  List<AgeEnum> ages;
  List<String> regions;
  List<XFile> images;

  FindSessionModel.init()
      : title = '',
        levels = [],
        sessions = [],
        ages = [],
        regions = [],
        images = [];
}

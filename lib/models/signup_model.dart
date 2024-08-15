import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';

class SignupModel {
  /// Required Fields
  late String nickname;
  late List<SessionEnum> sessions = [];
  late LevelEnum level;
  late AgeEnum age;

  /// Optional Fields
  late String contact;
  late List<XFile> images = [];
  late String bio;

  SignupModel.init()
      : nickname = '',
        sessions = [],
        level = LevelEnum.newbie,
        age = AgeEnum.gt20,
        contact = '',
        images = [],
        bio = '';

  toJson() {
    print('nickname: $nickname');
    print('sessions: $sessions');
    print('level: $level');
    print('age: $age');
    print('contact: $contact');
    print('images: $images');
    print('bio: $bio');
  }
}

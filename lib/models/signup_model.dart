import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';

class SignupModel {
  /// Required Fields
  String nickname;
  XFile? profileImage;
  List<SessionEnum> sessions;
  LevelEnum? level;
  AgeEnum? age;

  /// Optional Fields
  String? contact;
  List<XFile> images;
  String? bio;

  SignupModel.init()
      : nickname = '',
        sessions = [],
        images = [];

  toJson() {
    print('nickname: $nickname');
    print('profileImage: $profileImage');
    print('sessions: $sessions');
    print('level: $level');
    print('age: $age');
    print('contact: $contact');
    print('images: $images');
    print('bio: $bio');
  }
}

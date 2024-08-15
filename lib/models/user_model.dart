import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';

class UserModel {
  /// Required Fields
  late String email;
  late String nickname;
  late List<SessionEnum> sessions = [];
  late LevelEnum level;
  late AgeEnum age;

  /// Optional Fields
  late String contact;
  late List<XFile> images = [];
  late String bio;

  UserModel.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        nickname = json['nickname'],
        sessions = (json['sessions'] as List<dynamic>)
            .map((e) => SessionEnum.values
                .firstWhere((s) => s.toString() == 'SessionEnum.$e'))
            .toList(),
        level = LevelEnum.values
            .firstWhere((e) => e.toString() == 'LevelEnum.${json['level']}'),
        age = AgeEnum.values
            .firstWhere((e) => e.toString() == 'AgeEnum.${json['age']}'),
        contact = json['contact'],
        images = (json['images'] as List<dynamic>)
            .map((image) => XFile(image as String))
            .toList(),
        bio = json['bio'];
}

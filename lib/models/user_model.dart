import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/session_enum.dart';

class UserModel {
  /// Required Fields
  late String id;
  late String email;
  late String nickname;
  late List<SessionEnum> sessions = [];
  late AgeEnum age;

  /// Optional Fields
  late String? contact;
  late List<XFile> images = [];
  late XFile? profileImage;
  late String? bio;

  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        email = json['email'],
        nickname = json['nickname'],
        sessions = (json['sessions'] as List<dynamic>)
            .map((e) => SessionEnum.values
                .firstWhere((s) => s.toString() == 'SessionEnum.$e'))
            .toList(),
        age = AgeEnum.values
            .firstWhere((e) => e.toString() == 'AgeEnum.${json['age']}'),
        contact = json['contact'],
        profileImage =
            json['profile_image'] != null ? XFile(json['profile_image']) : null,
        images = (json['images'] as List<dynamic>)
            .map((image) => XFile(image as String))
            .toList(),
        bio = json['bio'];

  @override
  bool operator ==(Object other) {
    return other is UserModel && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}

import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/session_enum.dart';

enum SignupRequiredEnum { nickname, sessions }

class SignupModel {
  /// Required Fields
  String nickname;
  XFile? profileImage;
  List<SessionEnum> sessions;
  AgeEnum? age;

  /// Optional Fields
  String? contact;
  List<XFile> images;
  String? bio;

  SignupModel.init()
      : nickname = '',
        sessions = [],
        images = [];
}

import 'package:lets_jam/models/session_enum.dart';

class ProfileUploadModel {
  String nickname;
  List<SessionEnum> sessions;
  String contact;
  String bio;
  String profileImage;
  List<String> backgroundImages;

  ProfileUploadModel.init()
      : nickname = '',
        sessions = [],
        contact = '',
        bio = '',
        profileImage = '',
        backgroundImages = [];

  @override
  String toString() {
    return '{"nickname": "$nickname", "sessions": $sessions, "contact": "$contact", "bio": "$bio", "profileImage": "$profileImage", "backgroundImages": $backgroundImages}';
  }
}

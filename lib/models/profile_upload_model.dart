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
}

import 'package:lets_jam/models/genre_enum.dart';
import 'package:lets_jam/models/session_enum.dart';

class ProfileUploadModel {
  String nickname;
  List<SessionEnum> sessions;
  List<Genre> genres;
  String contact;
  String bio;
  String? profileImage;
  List<String>? backgroundImages;

  ProfileUploadModel.init()
      : nickname = '',
        sessions = [],
        genres = [],
        contact = '',
        bio = '',
        profileImage = null,
        backgroundImages = null;

  @override
  String toString() {
    return '{"nickname": "$nickname", "sessions": $sessions, "genres": $genres, "contact": "$contact", "bio": "$bio", "profileImage": "$profileImage", "backgroundImages": $backgroundImages}';
  }
}

import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/models/session_enum.dart';

class ProfileModel {
  /// Required Fields
  late String id;
  late String nickname;
  late List<SessionEnum> sessions = [];
  late String contact;

  /// Optional Fields
  late String? bio;
  late XFile? profileImage;
  late List<XFile>? backgroundImages = [];

  ProfileModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nickname = json['nickname'],
        sessions = (json['sessions'] as List<dynamic>?)
                ?.map((e) => SessionEnum.values
                    .firstWhere((s) => s.toString() == 'SessionEnum.$e'))
                .toList() ??
            [],
        contact = json['contact'] ?? '',
        profileImage =
            json['profile_image'] != null ? XFile(json['profile_image']) : null,
        backgroundImages = (json['background_images'] as List<dynamic>?)
                ?.map((image) => XFile(image as String))
                .toList() ??
            [],
        bio = json['bio'];

  @override
  bool operator ==(Object other) {
    return other is ProfileModel && other.id == id;
  }
}

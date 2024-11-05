import 'package:image_picker/image_picker.dart';
import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';

enum PostTypeEnum { findBand, findSession }

class PostModel {
  String id;
  DateTime createdAt;
  DateTime? modifiedAt;
  String userId;
  PostTypeEnum postType;
  String title;
  List<LevelEnum> levels;
  List<SessionEnum> sessions;
  List<AgeEnum>? ages;
  List<String>? regions;
  String contact;
  String description;
  List<XFile>? images;
  dynamic bandProfile;

  PostModel({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.postType,
    required this.title,
    required this.levels,
    required this.sessions,
    required this.contact,
    required this.description,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      postType: _postTypeFromString(json['post_type']),
      title: json['title'],
      levels: _levelsFromJson(json['levels']),
      sessions: _sesssionsFromJson(json['sessions']),
      contact: json['contact'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'postType': postType,
      'title': title,
      'levels': levels,
      'sessions': sessions,
      'contact': contact,
      'description': description,
    };
  }

  static PostTypeEnum _postTypeFromString(String postType) {
    switch (postType) {
      case 'find_band':
        return PostTypeEnum.findBand;
      case 'find_session':
        return PostTypeEnum.findSession;
      default:
        throw Exception('Invalid postType value: $postType');
    }
  }

  static List<LevelEnum> _levelsFromJson(List<dynamic> levelsJson) {
    return levelsJson
        .map((level) => _levelFromString(level as String))
        .toList();
  }

  static LevelEnum _levelFromString(String level) {
    switch (level) {
      case 'newbie':
        return LevelEnum.newbie;
      case 'beginner':
        return LevelEnum.beginner;
      case 'intermediate':
        return LevelEnum.intermediate;
      case 'advanced':
        return LevelEnum.advanced;
      default:
        throw Exception('Invalid level value: $level');
    }
  }

  static List<SessionEnum> _sesssionsFromJson(List<dynamic> sessionsJson) {
    return sessionsJson
        .map((session) => _sessionFromString(session as String))
        .toList();
  }

  static SessionEnum _sessionFromString(String session) {
    switch (session) {
      case 'vocal':
        return SessionEnum.vocal;
      case 'drum':
        return SessionEnum.drum;
      case 'guitar':
        return SessionEnum.guitar;
      case 'bass':
        return SessionEnum.bass;
      case 'keyboard':
        return SessionEnum.keyboard;
      case 'etc':
        return SessionEnum.etc;
      default:
        throw Exception('Invalid session value: $session');
    }
  }
}
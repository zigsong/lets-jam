import 'package:lets_jam/models/age_enum.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/region_enum.dart';
import 'package:lets_jam/models/session_enum.dart';

enum PostTypeEnum { findBand, findMember }

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
  List<District>? regions;
  String contact;
  String description;
  List<String>? tags;
  List<String>? images;
  dynamic bandProfile;
  int? replyCount;

  PostModel(
      {required this.id,
      required this.createdAt,
      required this.userId,
      required this.postType,
      required this.title,
      required this.levels,
      required this.sessions,
      required this.contact,
      required this.description,
      this.ages,
      this.regions,
      this.tags,
      this.images,
      this.replyCount});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      postType: _postTypeFromString(json['post_type']),
      title: json['title'],
      levels: _levelsFromJson(json['levels']),
      sessions: _sesssionsFromJson(json['sessions']),
      ages: _agesFromJson(json['ages']),
      regions: _regionsFromJson(json['regions']),
      contact: json['contact'],
      description: json['description'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      replyCount: json['comment_count'] != null
          ? (json['comment_count'] as List).length
          : null,
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
      'ages': ages,
      'regions': regions,
      'contact': contact,
      'description': description,
      'tags': tags,
      'images': images,
      'replyCount': replyCount
    };
  }

  static PostTypeEnum _postTypeFromString(String postType) {
    switch (postType) {
      case 'findBand':
        return PostTypeEnum.findBand;
      case 'findMember':
        return PostTypeEnum.findMember;
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
      case 'lv1':
        return LevelEnum.lv1;
      case 'lv2':
        return LevelEnum.lv2;
      case 'lv3':
        return LevelEnum.lv3;
      case 'lv4':
        return LevelEnum.lv4;
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
      case 'vocalM':
        return SessionEnum.vocalM;
      case 'vocalF':
        return SessionEnum.vocalF;
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

  static List<District> _regionsFromJson(List<dynamic> regionsJson) {
    return (regionsJson)
        .map((regionName) => District.values.firstWhere(
            (district) => district.displayName == regionName as String))
        .toList();
  }

  static List<AgeEnum> _agesFromJson(List<dynamic> agesJson) {
    return agesJson.map((age) => _ageFromString(age as String)).toList();
  }

  static AgeEnum _ageFromString(String age) {
    switch (age) {
      case 'lt20':
        return AgeEnum.lt20;
      case 'eq20s':
        return AgeEnum.eq20s;
      case 'eq30s':
        return AgeEnum.eq30s;
      case 'gt40':
        return AgeEnum.gt40;
      default:
        throw Exception('Invalid age value: $age');
    }
  }
}

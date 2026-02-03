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
  List<SessionEnum> sessions;
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
      required this.sessions,
      required this.contact,
      required this.description,
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
      sessions: _sesssionsFromJson(json['sessions']),
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
      'sessions': sessions,
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
}

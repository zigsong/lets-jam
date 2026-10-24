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
  bool isRecruiting;

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
      this.replyCount,
      this.isRecruiting = true});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      postType: _postTypeFromString(json['post_type']),
      title: json['title'],
      sessions: (json['sessions'] as List<dynamic>)
          .map((session) => SessionEnum.values.byName(session as String))
          .toList(),
      regions: (json['regions'] as List<dynamic>)
          .map((regionName) => District.fromDisplayName(regionName as String))
          .toList(),
      contact: json['contact'],
      description: json['description'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      replyCount: json['comment_count'] != null
          ? (json['comment_count'] as List).length
          : null,
      isRecruiting: json['is_recruiting'] ?? true,
    );
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
}

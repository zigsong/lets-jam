import 'package:lets_jam/models/profile_model.dart';

class ReplyModel {
  String id;
  DateTime createdAt;
  String postId;
  String userId;
  String content;
  ProfileModel? author;

  ReplyModel(
      {required this.id,
      required this.createdAt,
      required this.postId,
      required this.userId,
      required this.content,
      this.author});

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];

    return ReplyModel(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        postId: json['post_id'],
        userId: json['user_id'],
        content: json['content'],
        author: profile is Map<String, dynamic>
            ? ProfileModel.fromJson(profile)
            : null);
  }
}

class ReplyModel {
  String id;
  DateTime createdAt;
  String postId;
  String userId;
  String content;

  ReplyModel(
      {required this.id,
      required this.createdAt,
      required this.postId,
      required this.userId,
      required this.content});

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        postId: json['post_id'],
        userId: json['user_id'],
        content: json['content']);
  }
}

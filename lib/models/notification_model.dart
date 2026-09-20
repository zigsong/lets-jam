class NotificationModel {
  final String id;
  final DateTime createdAt;
  final String recipientId;
  final String? actorId;
  final String type;
  final String? postId;
  final String? commentId;
  final bool isRead;

  /// 조인된 게시글 제목 (posts.title)
  final String? postTitle;

  NotificationModel({
    required this.id,
    required this.createdAt,
    required this.recipientId,
    this.actorId,
    required this.type,
    this.postId,
    this.commentId,
    required this.isRead,
    this.postTitle,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final post = json['posts'];

    return NotificationModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      recipientId: json['recipient_id'],
      actorId: json['actor_id'],
      type: json['type'],
      postId: json['post_id'],
      commentId: json['comment_id'],
      isRead: json['is_read'] ?? false,
      postTitle: post is Map<String, dynamic> ? post['title'] as String? : null,
    );
  }
}

class EventComment {
  final String id;
  final String content;
  final String? stage;
  final String? userName;
  final String? userRole;
  final String createdAt;

  const EventComment({
    required this.id,
    required this.content,
    this.stage,
    this.userName,
    this.userRole,
    required this.createdAt,
  });

  factory EventComment.fromJson(Map<String, dynamic> json) {
    return EventComment(
      id: json['id'] as String,
      content: json['content'] as String,
      stage: json['stage'] as String?,
      userName: json['user_name'] as String?,
      userRole: json['user_role'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}
